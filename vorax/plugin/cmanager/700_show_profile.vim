" File:        vorax/plugin/cmanager/show_profile.vim
" Author:      Alexandru Tică
" Description: Show a profile from the connection profiles window.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'show',
      \ 'shortcut' : 's'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#ShowProfile()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return a:descriptor['profile'] != ''
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)

