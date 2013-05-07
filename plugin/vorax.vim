" File:        vorax.vim
" Author:      Alexandru Tică
" Description: An Oracle IDE for Geeks
" License:     see LICENSE.txt

let g:vorax_version = "4.0.0-beta"

if exists("g:loaded_vorax") || &cp
  finish
endif
let g:loaded_vorax = 1

" Bootstrap {{{

let s:old_cpo = &cpo
set cpo&vim

if v:version < 703 
  echo("Vorax needs Vim 7.3 or above!")
  finish
elseif v:version == 703 && !has('patch501')
  echo("Vorax requires the 501 patch for your Vim!")
  finish
end

" define the VoraX autocommand group
augroup VoraX

" }}}

" Configuration {{{

function! s:initVariable(var, value)
  if !exists(a:var)
    if type(a:value) == 0 || type(a:value) == 2 || type(a:value) == 5
      exec "let " . a:var . " = " . a:value
    else
      exec "let " . a:var . " = " . string(a:value)
    endif
    return 1
  endif
  return 0
endfunction

call s:initVariable('g:vorax_homedir', expand('~'))
call s:initVariable('g:vorax_map_keys', 1)
call s:initVariable('g:vorax_output_window_position', 'bottom')
call s:initVariable('g:vorax_output_window_size', 20)
call s:initVariable('g:vorax_output_window_statusline', '%!vorax#output#StatusLine()')
call s:initVariable('g:vorax_output_window_append', 0)
call s:initVariable('g:vorax_output_window_sticky_cursor', 0)
call s:initVariable('g:vorax_output_window_hl_error', 'Error')
call s:initVariable('g:vorax_output_abort_key', '<Esc>')

" The type of funnel:
"   0 = no funnel
"   1 = vertical
"   2 = pagezip
"   3 = tablezip
call s:initVariable('g:vorax_output_window_default_funnel', 0)
call s:initVariable('g:vorax_debug', 0)
call s:initVariable('g:vorax_throbber', ['|', '\', '-', '/'])
call s:initVariable('g:vorax_sqlplus_options', 
      \ ['set tab off',
      \  'set appinfo "VoraX"',
      \  'set arraysize 50',
      \  'set linesize 10000',
      \  'set timing on',
      \  'set echo on',
      \  'set time on',
      \  'set null "<NULL>"',
      \  'set serveroutput on format wrapped',
      \  'set sqlblanklines on'
      \ ])
call s:initVariable('g:vorax_parse_min_lines', 500)
call s:initVariable('g:vorax_update_session_owner', 1)
call s:initVariable('g:vorax_auto_connect', 1)
call s:initVariable('g:vorax_abort_session_warning', 0)

call s:initVariable('g:vorax_omni_enable', 1)
" The type of omni_case:
"   smart = use the case of the previous char before current position
"   upper = always uppercase
"   lower = always lowercase
"
" Everything else is assumed to be [lower].
call s:initVariable('g:vorax_omni_case', 'smart')
call s:initVariable('g:vorax_omni_max_items', 200)
call s:initVariable('g:vorax_omni_word_prefix_size', 2)
call s:initVariable('g:vorax_omni_parse_package', 1)
call s:initVariable('g:vorax_omni_force_upcase_const', 1)
call s:initVariable('g:vorax_omni_sort_items', 0)
call s:initVariable('g:vorax_omni_cache', ['SYS'])
call s:initVariable('g:vorax_omni_too_many_items_warn_delay', 500)

" Settings related to folding
call s:initVariable('g:vorax_folding_enable', 1)
" The initial state can be:
"   all_closed = all folds are initially closed
"   all_open = all folds are initially openned
call s:initVariable('g:vorax_folding_initial_state', 'all_open')

" the hash key is the object_type from DBMS_METADATA
call s:initVariable('g:vorax_file_associations',
      \ {'FUNCTION' : 'fnc',
      \  'PROCEDURE' : 'prc',
      \  'TRIGGER' : 'trg',
      \  'PACKAGE_SPEC' : 'spc',
      \  'PACKAGE_BODY' : 'bdy',
      \  'PACKAGE' : 'pkg',
      \  'TYPE_SPEC' : 'tps',
      \  'TYPE_BODY' : 'tpb',
      \  'TYPE' : 'typ',
      \  'JAVA_SOURCE' : 'jsp'})
exe 'autocmd BufRead,BufNewFile *.{' . join(values(g:vorax_file_associations), ',') . '} let &ft="sql" | SQLSetType plsqlvorax'

call s:initVariable('g:vorax_sql_script_default_extension', 'sql')
exe 'autocmd BufRead,BufNewFile *.' . g:vorax_sql_script_default_extension . ' SQLSetType sqlvorax'
" }}}

" Commands {{{

command! -n=1 VORAXConnect :call vorax#sqlplus#Connect(<q-args>)
command! -n=1 VORAXExec :call vorax#sqlplus#Exec(<q-args>)
command! -n=0 VORAXOutputToggle :call vorax#output#Toggle()

" }}}

" Key mappings {{{
if g:vorax_map_keys
  " global mappings
  nnoremap <silent> <Leader>o :VORAXOutputToggle<CR>

  " output window mappings
  au BufNew *__VORAX_OUTPUT__ 
        \ nnoremap <buffer> <silent> <Leader>cl :VORAXOutputClear<CR>|
        \ nnoremap <buffer> <silent> <Leader>v :VORAXOutputVertical<CR>|
        \ nnoremap <buffer> <silent> <Leader>p :VORAXOutputPagezip<CR>|
        \ nnoremap <buffer> <silent> <Leader>t :VORAXOutputTablezip<CR>|
        \ nnoremap <buffer> <silent> <Leader>a :VORAXOutputToggleAppend<CR>|
        \ nnoremap <buffer> <silent> <Leader>s :VORAXOutputToggleSticky<CR>|
        \ nnoremap <buffer> <silent> <CR> :VORAXOutputAskUser<CR>

  " mappings for SQL files
  au FileType sql
        \ nnoremap <buffer> <silent> <Leader>e :call vorax#sqlplus#Exec(vorax#utils#CurrentStatement(1, 1))<CR>|
        \ xnoremap <buffer> <silent> <Leader>e :VORAXExecSelection<CR>
endif

"}}}

" Custom colors {{{

" important connection (sysdba, sysoper etc)
hi User1 term=standout cterm=standout ctermfg=9 gui=reverse guifg=#cb4b16

" normal connection
hi User2 term=standout cterm=standout ctermfg=4 gui=reverse guifg=#268bd2

" throbber color
hi User3 term=standout cterm=standout ctermfg=5 gui=reverse guifg=#d33682

"}}}

" Logging Initialization {{{

function! VORAXDebug(message)
	" dummy function: do nothing
endfunction

if exists('g:vorax_debug') && g:vorax_debug == 1
  " because this automatically forces loading of voraxlib/ruby.vim,
  " the startup of Vim will be slower, but this shouldn't be a
  " problem assuming that the user explicitly turned on vorax logging
  try
    exe "call vorax#ruby#InitLogging(g:vorax_homedir . '/vorax.log')"

		function! VORAXDebug(message)
			if type(a:message) == 3 || type(a:message) == 4
				" a list or a dictionary
				let msg = string(a:message)
			else
				let msg = a:message
			endif
			exe "call vorax#ruby#Log(0, " . string(msg) . ")"
		endfunction

  catch /E117/
    echo "Sorry, don't expect VoraX to work properly!"
  endtry

endif

" }}}

let &cpo = s:old_cpo
