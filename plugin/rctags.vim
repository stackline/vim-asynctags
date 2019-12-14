command! RCTagsGenerate call rctags#tag_generate()
command! RCTagsJump call rctags#tag_jump()

augroup RCTags
  autocmd!
  " Suppress hit-enter prompt
  autocmd BufWritePost * silent execute('RCTagsGenerate')
augroup END
