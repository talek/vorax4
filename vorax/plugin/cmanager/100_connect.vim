" File:        vorax/plugin/cmanager/connect.vim
" Author:      Alexandru Tică
" Description: Connect using the selected profile.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'connect',
      \ 'shortcut' : 'o'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#ConnectUsingCurrentProfile()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] != ''
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)



