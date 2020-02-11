" Generate a tag file with root relative path asynchronously

" Check existence of necessary commands
function! s:extract_nonexistent_commands(cmds)
  let l:nonexistent_cmds = []

  for l:cmd in a:cmds
    if !executable(l:cmd)
      let l:nonexistent_cmds = add(l:nonexistent_cmds, l:cmd)
    endif
  endfor

  return l:nonexistent_cmds
endfunction

function! s:do_pre_processing()
  let l:nonexistent_cmds = s:extract_nonexistent_commands(['ctags', 'git', 'pwd'])
  if len(l:nonexistent_cmds) >= 1
    unsilent echom "[rctags.vim] can't find commands: " . join(l:nonexistent_cmds, ', ')
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
