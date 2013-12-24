" File:        vorax/plugin/explorer/open_spec.vim
" Author:      Alexandru Tică
" Description: Provides open spec plugin.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'open spec only',
      \ 'shortcut' : 's'}

function! s:plugin.Callback(descriptor)
  let dbtype = a:descriptor.dbtype . '_SPEC'
  let dbobject = a:descriptor['owner'] . '.' . a:descriptor['object']
  let bang = g:vorax_dbexplorer_force_edit ? '!' : ''
  call vorax#explorer#OpenDbObject(bang, dbtype, dbobject)
endfunction

function! s:plugin.IsEnabled(descriptor)
  if a:descriptor['category'] == 'Packages' ||
        \ a:descriptor['category'] == 'Types'
    return 1
  endif
  return 0
endfunction

call vorax#explorer#RegisterPluginItem(s:plugin)

