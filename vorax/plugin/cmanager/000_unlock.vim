" File:        vorax/plugin/cmanager/unlock.vim
" Author:      Alexandru Tică
" Description: Unlock the repository.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'unlock',
      \ 'shortcut' : 'u'}

function! s:plugin.Callback(descriptor)
  call vorax#cmanager#UnlockRepository()
endfunction

function! s:plugin.IsEnabled(descriptor)
  return !vorax#ruby#IsPmUnlocked()
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)



