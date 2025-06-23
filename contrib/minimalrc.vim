" Ensure this repo is at the top of the runtimepath
let &runtimepath = expand('<sfile>:p:h:h').','.&runtimepath
let g:netrw_dirhistmax = 0

set noswapfile
set viminfo=

if !has('nvim')
  set nocompatible
  filetype plugin on
  syntax on
endif

" ADD RELAVENT SETTINGS HERE TO REPRODUCE A ISSUE

" vim: ts=8 sts=2 sw=2 et
