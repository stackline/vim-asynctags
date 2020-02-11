command! RCTagsGenerate call rctags#tag_generate()
command! RCTagsJump call rctags#tag_jump()

augroup RCTags
  autocmd!
  " Use silent command to suppress hit-enter prompt
  autocmd BufWritePost * silent execute('RCTagsGenerate')
augroup END
