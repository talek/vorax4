" File:        vorax/plugin/explorer/new_object.vim
" Author:      Alexandru Tică
" Description: Provides new definiton plugin.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'new',
      \ 'shortcut' : 'n'}

function! s:plugin.Callback(descriptor)
  call vorax#explorer#NewDbObject(a:descriptor['dbtype'])
endfunction

function! s:plugin.IsEnabled(descriptor)
  return !vorax#utils#IsEmpty(a:descriptor['category']) &&
        \ a:descriptor['category'] != 'Users'
endfunction

call vorax#explorer#RegisterPluginItem(s:plugin)


