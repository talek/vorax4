" File:        vorax/plugin/cmanager/change_master_pwd.vim
" Author:      Alexandru Tică
" Description: Change the master password
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'change master password',
      \ 'shortcut' : 'x'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#ChangePassword()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return vorax#ruby#IsPmUnlocked()
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)



