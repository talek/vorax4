" File:        ftplugin/sqlvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when a SQL file is open
" License:     see LICENSE.txt

command! -n=0 -range -buffer VORAXExecSelection :call vorax#sqlplus#Exec(vorax#utils#CurrentSelection())

" set Vorax completion function
if g:vorax_omni_enable
  setlocal omnifunc=vorax#omni#Complete
endif

if exists('*VORAXAfterSqlBufferLoad')
	" Execute hook
	call VORAXAfterSqlBufferLoad()
endif

" signal that everything is setup
let b:did_ftplugin = 1

