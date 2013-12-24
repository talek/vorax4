" File:        vorax/plugin/cmanager/remove_profile.vim
" Author:      Alexandru Tică
" Description: Remove a profile from the connection profiles window.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'remove',
      \ 'shortcut' : 'r'}

function! s:plugin.Callback(descriptor)
  if confirm("Are you sure you want to remove the '" . a:descriptor['profile'] . "' profile?", "&Yes\n&No", 2) == 1
    call vorax#cmanager#RemoveProfile()
  endif
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] != ''
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)





