function! asynctags#statusline#backup() abort
  let g:asynctags#statusline#backup = &statusline
endfunction

function! asynctags#statusline#to_processing() abort
  let &statusline = 'Generating a tag...'
endfunction

function! asynctags#statusline#restore() abort
  let &statusline = g:asynctags#statusline#backup
endfunction
