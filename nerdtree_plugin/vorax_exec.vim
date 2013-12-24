" File:        vorax_exec.vim
" Author:      Alexandru Tică
" Description: An Oracle IDE for Geeks
" License:     see LICENSE.txt

" Add ! key to execute a node in vorax.
call NERDTreeAddKeyMap({
      \ 'key': '@', 
      \ 'quickhelpText': 'Execute file under VoraX.', 
      \ 'callback': 'NERDTreeVoraxExec'})

" Callback function to actually execute the vorax file.
function! NERDTreeVoraxExec()
  let treenode = g:NERDTreeFileNode.GetSelected()
  if !treenode.path.isDirectory
    let cmd = treenode.path.str({'escape': 0})
    " to address blanks in path on windows
    let cmd = fnamemodify(cmd, ':8')
      if vorax#utils#IsVoraxManagedFile(cmd)
        call vorax#sqlplus#SandboxExec('@"' . cmd . '"')
      else
        call vorax#utils#SpitWarn('Not a Vorax managed file.')
      endif
  endif
endfunction 

