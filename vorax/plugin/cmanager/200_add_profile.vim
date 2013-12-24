" File:        vorax/plugin/cmanager/add_profile.vim
" Author:      Alexandru Tică
" Description: Creates a new profile item.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'add profile',
      \ 'shortcut' : 'a'}

function! s:plugin.Callback(descriptor)
  let category = (a:descriptor['root'] ? '' : a:descriptor['category'])
  call vorax#cmanager#AddProfile('', category)
endfunction

function! s:plugin.IsEnabled(descriptor)
  return 1
endfunction

call vorax#cmanager#RegisterPluginItem(s:plugin)


