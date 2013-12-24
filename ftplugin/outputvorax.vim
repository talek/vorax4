" File:        ftplugin/outputvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when the output window is open
" License:     see LICENSE.txt

command! -n=0 -bar VORAXOutputClear :call vorax#output#Clear()
command! -n=0 -bar VORAXOutputVertical :call vorax#output#ToggleFunnel(1)
command! -n=0 -bar VORAXOutputPagezip :call vorax#output#ToggleFunnel(2)
command! -n=0 -bar VORAXOutputTablezip :call vorax#output#ToggleFunnel(3)
command! -n=0 -bar VORAXOutputToggleAppend :call vorax#output#ToggleAppend()
command! -n=0 -bar VORAXOutputToggleFullHeading :call vorax#output#ToggleFullHeading()
command! -n=0 -bar VORAXOutputToggleLimitRows :call vorax#output#ToggleLimitRows()
command! -n=0 -bar VORAXOutputToggleSticky :call vorax#output#ToggleSticky()
command! -n=0 -bar VORAXOutputToggleTop :call vorax#output#ToggleTop()
command! -n=0 -bar VORAXOutputAskUser :call vorax#output#AskUser()
command! -n=0 -bar VORAXOutputAbort :call vorax#output#Abort()

call vorax#toolkit#InitCommonBuffers()

if g:vorax_map_keys
  nnoremap <buffer> <silent> <Leader>cl :VORAXOutputClear<CR>
  nnoremap <buffer> <silent> <Leader>v :VORAXOutputVertical<CR>
  nnoremap <buffer> <silent> <Leader>p :VORAXOutputPagezip<CR>
  nnoremap <buffer> <silent> <Leader>t :VORAXOutputTablezip<CR>
  nnoremap <buffer> <silent> <Leader>a :VORAXOutputToggleAppend<CR>
  nnoremap <buffer> <silent> <Leader>h :VORAXOutputToggleFullHeading<CR>
  nnoremap <buffer> <silent> <Leader>lr :VORAXOutputToggleLimitRows<CR>
  nnoremap <buffer> <silent> <Leader>s :VORAXOutputToggleSticky<CR>
  nnoremap <buffer> <silent> <Leader>T :VORAXOutputToggleTop<CR>
  nnoremap <buffer> <silent> <CR> :VORAXOutputAskUser<CR>
endif
