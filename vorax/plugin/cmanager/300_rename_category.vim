" File:        vorax/plugin/cmanager/rename_category.vim
" Author:      Alexandru Tică
" Description: Rename a category from the connection profiles window.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'rename',
      \ 'shortcut' : 'm'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#RenameCategory()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] == '' && a:descriptor['root'] == 0
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)



