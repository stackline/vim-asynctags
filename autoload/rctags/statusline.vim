function! rctags#statusline#backup() abort
  let g:rctags#statusline#backup = &statusline
endfunction

function! rctags#statusline#to_processing() abort
  let &statusline = 'Generating a tag...'
endfunction

function! rctags#statusline#restore() abort
  let &statusline = g:rctags#statusline#backup
endfunction
