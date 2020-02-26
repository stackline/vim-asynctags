command! AsyncTagsGenerate call asynctags#tag_generate()
command! AsyncTagsJump call asynctags#tag_jump()

augroup AsyncTags
  autocmd!
  autocmd BufWritePost * execute('AsyncTagsGenerate')
augroup END
