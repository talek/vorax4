" File:        ftplugin/sqlvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when a SQL file is open
" License:     see LICENSE.txt

command! -n=0 -range -buffer VORAXExecSelection :call vorax#sqlplus#Exec(vorax#utils#CurrentSelection())
command! -n=0 -range -buffer VORAXExecCurrent :call vorax#sqlplus#Exec(vorax#utils#CurrentStatement(1, 1))
command! -n=0 -range -buffer VORAXSelectCurrent :call vorax#utils#SelectCurrentStatement()

command! -n=0 -range -buffer VORAXExecSbSelection :call vorax#sqlplus#SandboxExec(vorax#utils#CurrentSelection())
command! -n=0 -range -buffer VORAXExecSbCurrent :call vorax#sqlplus#SandboxExec(vorax#utils#CurrentStatement(1, 1))

command! -n=0 -range -buffer -bang VORAXExplain :call vorax#toolkit#Explain(vorax#utils#CurrentStatement(1, 1), '<bang>')
command! -n=0 -range -buffer -bang VORAXExplainSelection :call vorax#toolkit#Explain(vorax#utils#CurrentSelection(), '<bang>')

command! -n=0 -buffer VORAXExecBuffer :call vorax#utils#ExecBuffer()

call vorax#toolkit#InitCommonBuffers()

if g:vorax_map_keys
  " mappings for SQL file
  if g:vorax_key_sql_buffer_exec != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_buffer_exec . ' :VORAXExecBuffer<CR>'
  endif
  if g:vorax_key_sql_buffer_exec2 != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_buffer_exec2 . ' :VORAXExecBuffer<CR>'
  endif

  if g:vorax_key_sql_exec != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_exec . ' :VORAXExecCurrent<CR>'
  endif
  if g:vorax_key_sql_exec != ""
    exe 'xnoremap <buffer> <silent> ' . g:vorax_key_sql_exec . ' :VORAXExecSelection<CR>'
  endif
  if g:vorax_key_sql_select_current != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_select_current . ' :VORAXSelectCurrent<CR>'
  endif

  if g:vorax_key_sql_exec_sandbox != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_exec_sandbox . ' :VORAXExecSbCurrent<CR>'
  endif
  if g:vorax_key_sql_exec_sandbox != ""
    exe 'xnoremap <buffer> <silent> ' . g:vorax_key_sql_exec_sandbox . ' :VORAXExecSbSelection<CR>'
  endif

  if g:vorax_key_sql_explain_real != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_explain_real . ' :VORAXExplain!<CR>'
  endif
  if g:vorax_key_sql_explain_real != ""
    exe 'xnoremap <buffer> <silent> ' . g:vorax_key_sql_explain_real . ' :VORAXExplainSelection!<CR>'
  endif
  if g:vorax_key_sql_explain != ""
    exe 'nnoremap <buffer> <silent> ' . g:vorax_key_sql_explain . ' :VORAXExplain<CR>'
  endif
  if g:vorax_key_sql_explain != ""
    exe 'xnoremap <buffer> <silent> ' . g:vorax_key_sql_explain . ' :VORAXExplainSelection<CR>'
  endif
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

