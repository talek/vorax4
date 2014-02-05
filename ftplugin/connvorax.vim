" File:        ftplugin/connvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when the connection profiles window is open
" License:     see LICENSE.txt

augroup VoraxConnWin
  au!
  au BufLeave <buffer> setlocal nocursorline
  au BufEnter <buffer> setlocal cursorline
augroup END
