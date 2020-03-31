let s:suite = themis#suite('statusline')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  let &statusline = '%F'
  unlet! g:asynctags#statusline#backup
endfunction

" Save current statusline setting
function! s:suite.backup()
  " before
  call s:assert.false(exists('g:asynctags#statusline#backup'))

  " execute function
  call asynctags#statusline#backup()

  " after
  call s:assert.true(exists('g:asynctags#statusline#backup'))
  call s:assert.equals(g:asynctags#statusline#backup, '%F')
endfunction

" Update statusline while processing
function! s:suite.to_processing()
  " before
  call s:assert.equals(&statusline, '%F')

  " execute function
  call asynctags#statusline#to_processing()

  " after
  call s:assert.equals(&statusline, 'Generating a tag...')
endfunction

" Update statusline with backup setting
function! s:suite.restore() abort
  " before
  call s:assert.equals(&statusline, '%F')

  " execute function
  let g:asynctags#statusline#backup = '%F\ \|\ %{&ft}'
  call asynctags#statusline#restore()

  " after
  call s:assert.equals(&statusline, '%F\ \|\ %{&ft}')
endfunction
