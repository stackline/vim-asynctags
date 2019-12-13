" Generate a tag file with root relative path asynchronously

" Check existence of necessary commands
function! s:ExtractNonexistentCommands(cmds)
  let l:nonexistent_cmds = []

  for l:cmd in a:cmds
    if !executable(l:cmd)
      let l:nonexistent_cmds = add(l:nonexistent_cmds, l:cmd)
    endif
  endfor

  return l:nonexistent_cmds
endfunction

function! s:GenerateTag() abort
  let l:nonexistent_cmds = s:ExtractNonexistentCommands(['ctags', 'git', 'pwd'])
  if len(l:nonexistent_cmds) >= 1
    unsilent echom "[rctags.vim] can't find commands: " . join(l:nonexistent_cmds, ', ')
    return 0
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
  else
    echom '[rctags.vim] ctags failed to start'
  endif

  " Move to current directory
  execute 'tcd ' . l:current_dir
endfunction

command! RCTagsGenerate call s:GenerateTag()

function! s:JumpToTagLocation() abort
  let l:current_dir = system('pwd')
  let l:root_dir = system('git rev-parse --show-toplevel')

  execute 'tcd ' . l:root_dir
  execute 'tjump ' . expand("<cword>")
  execute 'tcd ' . l:current_dir
endfunction

command! RCTagsJump call s:JumpToTagLocation()

augroup RCTags
  autocmd!
  " Suppress hit-enter prompt
  autocmd BufWritePost * silent execute('RCTagsGenerate')
augroup END
