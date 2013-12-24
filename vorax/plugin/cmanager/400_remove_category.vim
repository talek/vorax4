" File:        vorax/plugin/cmanager/remove_category.vim
" Author:      Alexandru Tică
" Description: Remove a category from the connection profiles window.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'remove',
      \ 'shortcut' : 'r'}

function! s:plugin.Callback(descriptor)
  if confirm("All assigned profiles will be removed too. Are you sure you want to continue?", "&Yes\n&No", 2) == 1
    call vorax#cmanager#RemoveCategory()
  endif
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] == '' && a:descriptor['root'] == 0
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)




