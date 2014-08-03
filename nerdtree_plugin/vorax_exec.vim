" File:        vorax_exec.vim
" Author:      Alexandru Tică
" Description: An Oracle IDE for Geeks
" License:     see LICENSE.txt

" guard against sourcing the script twice
if exists("g:loaded_nerdtree_vorax_exec")
  finish
endif
let g:loaded_nerdtree_vorax_exec = 1

let s:vorax_nerdtree_exec_key = exists('g:vorax_nerdtree_exec_key') ? g:vorax_nerdtree_exec_key : '@'
let s:vorax_nerdtree_sbexec_key = exists('g:vorax_nerdtree_sbexec_key') ? g:vorax_nerdtree_sbexec_key : '!'

" Add key to execute a node in vorax.
call NERDTreeAddKeyMap({
      \ 'key': s:vorax_nerdtree_exec_key, 
      \ 'quickhelpText': 'Execute a SQL file under VoraX.', 
      \ 'callback': 'NERDTreeVoraxExec'})

call NERDTreeAddKeyMap({
      \ 'key': s:vorax_nerdtree_sbexec_key, 
      \ 'quickhelpText': 'Execute a SQL file in sandbox mode under VoraX.', 
      \ 'callback': 'NERDTreeVoraxSbExec'})

"add a menu separator (a row of dashes) before our new menu item
call NERDTreeAddMenuSeparator({
    \ 'isActiveCallback': 'NERDTreeVoraxExecEnabled'})

"add Vorax menu items
call NERDTreeAddMenuItem({
    \ 'text': '(e)xecute SQL',
    \ 'shortcut': 'e',
    \ 'isActiveCallback': 'NERDTreeVoraxExecEnabled',
    \ 'callback': 'NERDTreeVoraxExec' })

call NERDTreeAddMenuItem({
    \ 'text': 'e(x)ecute SQL in sandbox',
    \ 'shortcut': 'x',
    \ 'isActiveCallback': 'NERDTreeVoraxExecEnabled',
    \ 'callback': 'NERDTreeVoraxSbExec' })

function s:IsEnabled(treenode)
  let treenode = a:treenode
  if !treenode.path.isDirectory
    let cmd = treenode.path.str({'escape': 0})
    " to address blanks in path on windows
    let cmd = fnamemodify(cmd, ':8')
      if vorax#utils#IsVoraxManagedFile(cmd)
        return 1
      else
        return 0
      endif
  endif
endfunction

function NERDTreeVoraxExecEnabled()
  let treenode = g:NERDTreeFileNode.GetSelected()
  return s:IsEnabled(treenode)
endfunction

function! NERDTreeVoraxExec()
  let treenode = g:NERDTreeFileNode.GetSelected()
  if s:IsEnabled(treenode)
    let cmd = fnamemodify(treenode.path.str({'escape': 0}), ':8')
    call vorax#sqlplus#Exec('@"' . cmd . '"')
  else
    call vorax#utils#SpitWarn('Not a Vorax managed file.')
  endif
endfunction 

function! NERDTreeVoraxSbExec()
  let treenode = g:NERDTreeFileNode.GetSelected()
  if s:IsEnabled(treenode)
    let cmd = fnamemodify(treenode.path.str({'escape': 0}), ':8')
    call vorax#sqlplus#SandboxExec('@"' . cmd . '"')
  else
    call vorax#utils#SpitWarn('Not a Vorax managed file.')
  endif
endfunction 
