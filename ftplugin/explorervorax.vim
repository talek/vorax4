" File:        ftplugin/explorervorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when the DB explorer window is open
" License:     see LICENSE.txt

augroup VoraxExplorerWin
  au!
  au BufLeave <buffer> setlocal nocursorline
  au BufEnter <buffer> setlocal cursorline
augroup END
