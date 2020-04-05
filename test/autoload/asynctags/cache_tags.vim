let s:suite = themis#suite('asynctags#cache_tags')
let s:assert = themis#helper('assert')

function! s:suite.before_each() abort
  let $HOME = '/home/user_id'
endfunction

function! s:suite.get_directory_with_uri_pattern() abort
  let l:remote_url = 'ssh://git@github.com:1234/username/repository.git'
  call asynctags#cache_tags#initialize(l:remote_url)
  let l:directory = asynctags#cache_tags#get_directory()

  call s:assert.equals(l:directory, '/home/user_id/.cache/vim-asynctags/username/repository')
endfunction

function! s:suite.get_directory_with_scp_pattern() abort
  let l:remote_url = 'git@github.com:username/repository.git'
  call asynctags#cache_tags#initialize(l:remote_url)
  let l:directory = asynctags#cache_tags#get_directory()

  call s:assert.equals(l:directory, '/home/user_id/.cache/vim-asynctags/username/repository')
endfunction

function! s:suite.get_directory_with_error_pattern() abort
  let l:exception_catching = v:false
  let l:remote_url = 'error_url'
  try
    call asynctags#cache_tags#initialize(l:remote_url)
  catch /^\[vim-asynctags\] Detect unsupported URL: error_url$/
    let l:exception_catching = v:true
  endtry

  call s:assert.equals(l:exception_catching, v:true)
endfunction
