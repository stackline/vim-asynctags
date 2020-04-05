let s:URI_PATTERN = '\v^([a-z]+)://([a-z]+\@)?([a-z0-9.]+)(:[0-9]+)?/(.+)$'
let s:SCP_PATTERN = '\v^([a-z]+\@)([a-z0-9.]+):(.+)$'

function! s:normalize_url(url) abort
  let l:url = substitute(a:url, "\n", '', '')
  let l:url = substitute(l:url, '.git$', '', '')
  return l:url
endfunction

function! asynctags#cache_tags#initialize(remote_url) abort
  let l:remote_url = s:normalize_url(a:remote_url)
  let l:uri_pattern_matched = matchlist(l:remote_url, s:URI_PATTERN)
  let l:scp_pattern_matched = matchlist(l:remote_url, s:SCP_PATTERN)

  if len(l:uri_pattern_matched) > 0
    let l:path = substitute(l:uri_pattern_matched[5], '.git$', '', '')
    let s:cache_directory = join([$HOME, '.cache', 'vim-asynctags', l:path], '/')
  elseif len(l:scp_pattern_matched) > 0
    let l:path = substitute(l:scp_pattern_matched[3], '.git$', '', '')
    let s:cache_directory = join([$HOME, '.cache', 'vim-asynctags', l:path], '/')
  else
    throw '[vim-asynctags] Detect unsupported URL: ' . a:remote_url
  endif
endfunction

function! asynctags#cache_tags#get_directory() abort
  return s:cache_directory
endfunction

function! asynctags#cache_tags#get_file_path() abort
  return s:cache_directory . '/tags.tmp'
endfunction
