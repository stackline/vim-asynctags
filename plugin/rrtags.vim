" Generate a tag file with root relative path asynchronously
function! s:generate_tag() abort
  " Check existence of necessary commands
  let l:necessary_cmds = ['ctags', 'git', 'pwd']
  let l:error_cmds = []

  for l:necessary_cmd in l:necessary_cmds
    let l:return_code = executable(l:necessary_cmd)
    if l:return_code != 1
      let l:error_cmds = add(l:error_cmds, l:necessary_cmd)
    endif
  endfor

  if len(l:error_cmds) >= 1
    echom "[rrtags.vim] can't find commands: " . join(l:error_cmds, ", ")
    return 0
  endif

  " Move to root directory
  let l:current_dir = system('pwd')
  let l:root_dir = system('git rev-parse --show-toplevel')
  execute 'tcd ' . l:root_dir

  " Generate a tag file
  let l:ctags_opts = get(g:, 'rrtags_ctags_opts', ['-R'])
  let l:cmd = ['ctags'] + l:ctags_opts

  function! s:stdout_handler(job_id, data, event_type)
    echom '[rrtags.vim] [' . a:event_type . '] ' . join(a:data, "\n")
  endfunction

  function! s:exit_handler(job_id, status, event_type)
    if a:status == 0
      echom '[rrtags.vim] ctags succeeded to generate (status code: ' . a:status . ')'
    else
      echom '[rrtags.vim] ctags failed to generate (status code: ' . a:status . ')'
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
    echom '[rrtags.vim] ' . v:exception
    " Move to current directory
    execute 'tcd ' . l:current_dir
    return 0
  endtry

  if l:jobid > 0
    echom '[rrtags.vim] ctags started'
  else
    echom '[rrtags.vim] ctags failed to start'
  endif

  " Move to current directory
  execute 'tcd ' . l:current_dir
endfunction

command! RRTagsGenerate call s:generate_tag()

function! s:jump_to_tag_location() abort
  let l:current_dir = system('pwd')
  let l:root_dir = system('git rev-parse --show-toplevel')

  execute 'tcd ' . l:root_dir
  execute 'tjump ' . expand("<cword>")
  execute 'tcd ' . l:current_dir
endfunction

command! RRTagsJump call s:jump_to_tag_location()

augroup RRTags
  autocmd!
  " Suppress hit-enter prompt
  autocmd BufWritePost * silent execute('RRTagsGenerate')
augroup END
