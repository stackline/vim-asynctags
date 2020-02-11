" Generate a tag file with root relative path asynchronously

" TODO: Check if neovim supports const
let s:REQUIRED_COMMANDS = ['ctags', 'git', 'pwd']
lockvar s:REQUIRED_COMMANDS

function! s:get_non_executable_commands(commands)
  " filter function overwrites the argument
  return filter(deepcopy(a:commands), { index, command -> !executable(command) })
endfunction

function! s:do_pre_processing()
  let l:non_executable_commands = s:get_non_executable_commands(s:REQUIRED_COMMANDS)
  if len(l:non_executable_commands) >= 1
    unsilent echom "[rctags.vim] can't find commands: " . join(l:non_executable_commands, ', ')
    return v:false
  endif

  return v:true
endfunction

function! s:tag_generate() abort
  let l:err = s:do_pre_processing()
  if l:err == v:false
    return l:err
  endif

  " Move to root directory
  let l:current_dir = system('pwd')
  let l:root_dir = system('git rev-parse --show-toplevel')
  execute 'tcd ' . l:root_dir

  " Generate a tag file
  let l:ctags_opts = get(g:, 'rctags_ctags_opts', ['-R'])
  let l:cmd = ['ctags'] + l:ctags_opts

  function! s:stdout_handler(job_id, data, event_type)
    echom '[rctags.vim] [' . a:event_type . '] ' . join(a:data, "\n")
  endfunction

  function! s:exit_handler(job_id, status, event_type)
    " Show progress in status line
    call rctags#statusline#restore()

    if a:status == 0
      echom '[rctags.vim] ctags succeeded to generate (status code: ' . a:status . ')'
    else
      echom '[rctags.vim] ctags failed to generate (status code: ' . a:status . ')'
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
    echom '[rctags.vim] ' . v:exception
    " Move to current directory
    execute 'tcd ' . l:current_dir
    return 0
  endtry

  if l:jobid > 0
    echom '[rctags.vim] ctags started'
    " Show progress in status line
    call rctags#statusline#backup()
    call rctags#statusline#to_processing()
  else
    echom '[rctags.vim] ctags failed to start'
  endif

  " Move to current directory
  execute 'tcd ' . l:current_dir
endfunction

function! s:tag_jump() abort
  let l:current_dir = system('pwd')
  let l:root_dir = system('git rev-parse --show-toplevel')

  execute 'tcd ' . l:root_dir
  execute 'tjump ' . expand("<cword>")
  execute 'tcd ' . l:current_dir
endfunction

" public apis
function! rctags#tag_generate() abort
  return s:tag_generate()
endfunction

function! rctags#tag_jump() abort
  return s:tag_jump()
endfunction
