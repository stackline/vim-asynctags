" Plugin configurations
let g:asynctags_ctags_command = get(g:, 'asynctags_ctags_command', 'ctags')
let g:asynctags_ctags_options = get(g:, 'asynctags_ctags_opts', '-R')

command! AsyncTagsGenerate call asynctags#tag_generate()
command! AsyncTagsJump call asynctags#tag_jump()

augroup AsyncTags
  autocmd!
  autocmd BufWritePost * execute('AsyncTagsGenerate')
augroup END
