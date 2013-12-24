" File:        vorax/plugin/explorer/drop_object.vim
" Author:      Alexandru Tică
" Description: Provides drop object plugin.
" License:     see LICENSE.txt

let s:plugin = {
      \ 'text': 'drop object',
      \ 'shortcut' : 'r'}

function! s:plugin.Callback(descriptor)
  let dbtype = a:descriptor.dbtype
  if !vorax#utils#IsEmpty(a:descriptor['object'])
    if a:descriptor['category'] == 'Users' || 
          \ a:descriptor['category'] == 'DB Links'
      let dbobject = '"' . a:descriptor['object'] . '"'
    else
      let dbobject = '"' . a:descriptor['owner'] . '"."' . 
            \ a:descriptor['object'] . '"'
    endif
    if exists('dbobject')
      let cmd = 'DROP '
      if a:descriptor['dbtype'] == 'DB_LINK'
        let cmd .= 'DATABASE LINK '
      else
        let cmd .= substitute(a:descriptor['dbtype'], '_', ' ', 'g') . ' '
      end
      let cmd .= dbobject . ' '
      if a:descriptor['dbtype'] == 'TABLE'
        let cmd .= 'CASCADE CONSTRAINTS;'
      elseif a:descriptor['dbtype'] == 'USER'
        let cmd .= 'CASCADE;'
      else
        let cmd .= ';'
      endif
      if confirm("Confirm you want to run: \n" . cmd, "&Yes\n&No", 2) == 1
        let output = vorax#sqlplus#ExecImmediate(cmd)
        call vorax#output#SpitAll(output)
        call vorax#explorer#Refresh()
      endif
    endif
  endif
endfunction

function! s:plugin.IsEnabled(descriptor)
  return vorax#utils#IsEmpty(a:descriptor['object']) ? 0 : 1
endfunction

call vorax#explorer#RegisterPluginItem(s:plugin)

