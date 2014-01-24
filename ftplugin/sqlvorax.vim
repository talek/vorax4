" File:        ftplugin/sqlvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when a SQL file is open
" License:     see LICENSE.txt

command! -n=0 -range -buffer VORAXExecSelection :call vorax#sqlplus#Exec(vorax#utils#CurrentSelection())
command! -n=0 -range -buffer VORAXExecCurrent :call vorax#sqlplus#Exec(vorax#utils#CurrentStatement(1, 1))

command! -n=0 -range -buffer VORAXExecSbSelection :call vorax#sqlplus#SandboxExec(vorax#utils#CurrentSelection())
command! -n=0 -range -buffer VORAXExecSbCurrent :call vorax#sqlplus#SandboxExec(vorax#utils#CurrentStatement(1, 1))

command! -n=0 -range -buffer -bang VORAXExplain :call vorax#toolkit#Explain(vorax#utils#CurrentStatement(1, 1), '<bang>')
command! -n=0 -range -buffer -bang VORAXExplainSelection :call vorax#toolkit#Explain(vorax#utils#CurrentSelection(), '<bang>')

command! -n=0 -buffer VORAXExecBuffer :call vorax#sqlplus#Exec(vorax#utils#BufferContent())

call vorax#toolkit#InitCommonBuffers()

if g:vorax_map_keys
  " mappings for SQL file
  nnoremap <buffer> <silent> <leader>be :VORAXExecBuffer<CR>
  nnoremap <buffer> <silent> K :call vorax#oradoc#Search(expand('<cWORD>'))<CR>

  nnoremap <buffer> <silent> <Leader>e :VORAXExecCurrent<CR>
  xnoremap <buffer> <silent> <Leader>e :VORAXExecSelection<CR>

  nnoremap <buffer> <silent> <Leader>E :VORAXExecSbCurrent<CR>
  xnoremap <buffer> <silent> <Leader>E :VORAXExecSbSelection<CR>

  nnoremap <buffer> <silent> <Leader>x :VORAXExplain!<CR>
  xnoremap <buffer> <silent> <Leader>x :VORAXExplainSelection!<CR>
  nnoremap <buffer> <silent> <Leader>X :VORAXExplain<CR>
  xnoremap <buffer> <silent> <Leader>X :VORAXExplainSelection<CR>
endif

" set Vorax completion function
if g:vorax_omni_enable
  setlocal omnifunc=vorax#omni#Complete
endif

if exists('*VORAXAfterSqlBufferLoad')
  " Execute hook
  call VORAXAfterSqlBufferLoad()
endif

" Needed in order Vorax parser to work
setlocal nobinary

" signal that everything is setup
let b:did_ftplugin = 1

