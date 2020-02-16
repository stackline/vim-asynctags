command! RCTagsGenerate call rctags#tag_generate()
command! RCTagsJump call rctags#tag_jump()

augroup RCTags
  autocmd!
  autocmd BufWritePost * execute('RCTagsGenerate')
augroup END
