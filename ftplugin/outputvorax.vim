" File:        ftplugin/outputvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when the output window is open
" License:     see LICENSE.txt

if exists('s:initialized')
  finish
endif

let s:initialized = 1


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
  if g:vorax_key_output_clear != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_clear . ' :VORAXOutputClear<CR>'
  endif
  if g:vorax_key_output_vertical != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_vertical . ' :VORAXOutputVertical<CR>'
  endif
  if g:vorax_key_output_pagezip != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_pagezip . ' :VORAXOutputPagezip<CR>'
  endif
  if g:vorax_key_output_tablezip != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_tablezip . ' :VORAXOutputTablezip<CR>'
  endif
  if g:vorax_key_output_append != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_append . ' :VORAXOutputToggleAppend<CR>'
  endif
  if g:vorax_key_output_toggle_full_heading != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_toggle_full_heading . ' :VORAXOutputToggleFullHeading<CR>'
  endif
  if g:vorax_key_output_toggle_limit_rows != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_toggle_limit_rows . ' :VORAXOutputToggleLimitRows<CR>'
  endif
  if g:vorax_key_output_toggle_sticky != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_toggle_sticky . ' :VORAXOutputToggleSticky<CR>'
  endif
  if g:vorax_key_output_toggle_top != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_toggle_top . ' :VORAXOutputToggleTop<CR>'
  endif
  if g:vorax_key_output_ask_user != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_output_ask_user . ' :VORAXOutputAskUser<CR>'
  endif
endif

augroup VoraxOutputWin
  au!

  if g:vorax_omni_output_window_items
    au BufLeave,VimResized <buffer> call vorax#output#SetVisibleBounds()
  endif
  
  au WinLeave <buffer> setlocal nocursorline
  au BufEnter <buffer> setlocal cursorline
augroup END
