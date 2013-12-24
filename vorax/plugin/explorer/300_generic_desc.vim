" File:        vorax/plugin/explorer/describe.vim
" Author:      Alexandru Tică
" Description: Provides describe object plugin.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'describe',
      \ 'shortcut' : 'd'}

function! s:plugin.Callback(descriptor)
  let dbtype = a:descriptor.dbtype
  if !vorax#utils#IsEmpty(a:descriptor['object'])
    if a:descriptor['category'] == 'Users' || a:descriptor['category'] == 'DB Links'
      let dbobject = a:descriptor['object']
    else
      let dbobject = a:descriptor['owner'] . '.' . a:descriptor['object']
    endif
    if exists('dbobject')
      call vorax#toolkit#Desc(dbobject, '')
    endif
  endif
endfunction

function! s:plugin.IsEnabled(descriptor)
  if vorax#utils#IsEmpty(a:descriptor['object'])
    return 0
  endif
  if a:descriptor['category'] == 'Tables' ||
        \ a:descriptor['category'] == 'Views' ||
        \ a:descriptor['category'] == 'Packages' ||
        \ a:descriptor['category'] == 'Types' ||
        \ a:descriptor['category'] == 'Functions' ||
        \ a:descriptor['category'] == 'Procedures'
    return 1
  else
    return 0
  endif
endfunction

function! VORAXGenericDescPlugin(descriptor)
  if s:plugin.IsEnabled(a:descriptor)
    call s:plugin.Callback(a:descriptor)
  endif
endfunction

noremap <silent> <buffer> <Leader>d :call VORAXGenericDescPlugin(vorax#explorer#CurrentNodeProperties())<CR>

call vorax#explorer#RegisterPluginItem(s:plugin)


