" File:        vorax/plugin/explorer/open_def.vim
" Author:      Alexandru Tică
" Description: Provides open definiton plugin.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'open',
      \ 'shortcut' : 'o'}

function! s:plugin.Callback(descriptor)
  call vorax#explorer#OpenCurrentNode()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return vorax#utils#IsEmpty(a:descriptor['object']) ? 0 : 1
endfunction

call vorax#explorer#RegisterPluginItem(s:plugin)

