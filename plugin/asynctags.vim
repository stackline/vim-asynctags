" Plugin configurations
let g:asynctags_ctags_command = get(g:, 'asynctags_ctags_command', 'ctags')
let g:asynctags_ctags_options = get(g:, 'asynctags_ctags_opts', '-R')

command! AsyncTagsGenerate call asynctags#tag_generate()
command! AsyncTagsJump call asynctags#tag_jump()

let s:quitting = 0

function s:execute_async_tags_generate()
  if s:quitting == 0
    execute('AsyncTagsGenerate')
  endif
endfunction

augroup AsyncTags
  autocmd!
  autocmd QuitPre * let s:quitting = 1
  autocmd BufWritePost * :call s:execute_async_tags_generate()
augroup END
