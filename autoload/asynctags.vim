" Generate a tag file with root relative path asynchronously

" TODO: Check if neovim supports const
let s:REQUIRED_COMMANDS = ['ctags', 'pgrep', 'git']
lockvar s:REQUIRED_COMMANDS
let s:CTAGS_EXIT_SUCCESS = 0
lockvar s:CTAGS_EXIT_SUCCESS
let s:PGREP_NO_PROCESSES_MATCHED = 1
lockvar s:PGREP_NO_PROCESSES_MATCHED

function! s:get_non_executable_commands(commands)
  " filter function overwrites the argument
  return filter(deepcopy(a:commands), { index, command -> !executable(command) })
endfunction

" Build work directory from git remote URL like below
"
" * git@[hostname]:user/repo.git
" * https://[hostname]/user/repo.git
"
function! s:get_work_directory()
  if exists('s:cached_work_directory')
    return s:cached_work_directory
  endif

  let l:git_remote_url = system('git config --get remote.origin.url')
  let l:normalized_url = substitute(l:git_remote_url, "\n$", '', '')
  let l:normalized_url = substitute(l:normalized_url, '.git$', '', '')
  let l:normalized_url = substitute(l:normalized_url, ':', '/', 'g')

  let l:url_parts = split(l:normalized_url, '/')
  let l:number_of_parts = len(l:url_parts)

  let l:user = l:url_parts[l:number_of_parts - 2]
  let l:repository = l:url_parts[l:number_of_parts - 1]

  let s:cached_work_directory = join([$HOME, '.cache', 'vim-asynctags', l:user, l:repository], '/')
  return s:cached_work_directory
endfunction

function! s:do_pre_processing()
  let l:non_executable_commands = s:get_non_executable_commands(s:REQUIRED_COMMANDS)
  if len(l:non_executable_commands) >= 1
    echom "[asynctags.vim] can't find commands: " . join(l:non_executable_commands, ', ')
    return v:false
  endif

  let l:work_directory = s:get_work_directory()
  if !isdirectory(l:work_directory)
    call mkdir(l:work_directory, 'p')
  endif

  return v:true
endfunction

function! s:build_temporary_tagfile_path()
  return s:get_work_directory() . '/tags.tmp'
endfunction

function! s:tag_generate() abort
  let l:err = s:do_pre_processing()
  if l:err == v:false
    return l:err
  endif

  " Move to root directory
  let l:current_dir = getcwd()
  let l:root_dir = system('git rev-parse --show-toplevel')
  execute 'tcd ' . l:root_dir

  " Generate a tag file
  " TODO: Support ripper-tags
  let l:ctags_command = 'ctags'
  let l:ctags_file_option = '-f ' . s:build_temporary_tagfile_path()
  let l:ctags_user_options = get(g:, 'asynctags_ctags_opts', '-R')
  let l:cmd = [l:ctags_command, l:ctags_file_option] + l:ctags_user_options

  call system('pgrep -f "' . join(l:cmd, ' ') . '"')
  if v:shell_error != s:PGREP_NO_PROCESSES_MATCHED
    echom "[asynctags.vim] can't start ctags twice"
    return v:false
  endif

  function! s:stdout_handler(job_id, data, event_type)
    echom '[asynctags.vim] [' . a:event_type . '] ' . join(a:data, "\n")
  endfunction

  function! s:exit_handler(job_id, status, event_type)
    " Show progress in status line
    call asynctags#statusline#restore()

    if a:status == s:CTAGS_EXIT_SUCCESS
      let l:source_file = s:build_temporary_tagfile_path()
      let l:root_dir = system('git rev-parse --show-toplevel | tr -d "\n"')
      let l:target_file = l:root_dir . '/tags'
      call system(join(['cp', l:source_file, l:target_file], ' '))

      echom '[asynctags.vim] ctags succeeded to generate (status code: ' . a:status . ')'
    else
      echom '[asynctags.vim] ctags failed to generate (status code: ' . a:status . ')'
    endif
  endfunction

  let l:opts = {
        \ 'on_stdout': function('s:stdout_handler'),
        \ 'on_stderr': function('s:stdout_handler'),
        \ 'on_exit': function('s:exit_handler'),
        \ }

  try
    let l:jobid = async#job#start(l:cmd, l:opts)
  catch
    echom '[asynctags.vim] ' . v:exception
    " Move to current directory
    execute 'tcd ' . l:current_dir
    return 0
  endtry

  if l:jobid > 0
    " Use silent command to suppress hit-enter prompt
    silent echom '[asynctags.vim] ctags started'
    " Show progress in status line
    call asynctags#statusline#backup()
    call asynctags#statusline#to_processing()
  else
    echom '[asynctags.vim] ctags failed to start'
  endif

  " Move to current directory
  execute 'tcd ' . l:current_dir
endfunction

function! s:tag_jump() abort
  let l:current_dir = getcwd()
  let l:root_dir = system('git rev-parse --show-toplevel')

  execute 'tcd ' . l:root_dir
  execute 'tjump ' . expand("<cword>")
  execute 'tcd ' . l:current_dir
endfunction

" public apis
function! asynctags#tag_generate() abort
  return s:tag_generate()
endfunction

function! asynctags#tag_jump() abort
  return s:tag_jump()
endfunction
