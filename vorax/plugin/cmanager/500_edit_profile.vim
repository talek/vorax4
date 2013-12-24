" File:        vorax/plugin/cmanager/edit_profile.vim
" Author:      Alexandru Tică
" Description: Edit a profile from the connection profiles window.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'edit',
      \ 'shortcut' : 'e'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#ChangeProfile()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] != ''
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)


