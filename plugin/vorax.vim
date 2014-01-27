" File:        vorax.vim
" Author:      Alexandru Tică
" Description: An Oracle IDE for Geeks
" License:     see LICENSE.txt

let g:vorax_version = "4.3.3"

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

" not a very bad idea to set the filetype plugin on.
" It doesn't guarantee that another plugin or the user has
" disabled this feature, but may be useful for simple
" startup configurations.
filetype plugin on

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
call s:initVariable('g:vorax_output_cursor_on_top', 0)
call s:initVariable('g:vorax_output_full_heading', 0)

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
      \  'set null ""',
      \  'set serveroutput on format wrapped',
      \  'set sqlblanklines on'
      \ ])
call s:initVariable('g:vorax_parse_min_lines', 500)
call s:initVariable('g:vorax_update_session_owner', 1)
call s:initVariable('g:vorax_auto_connect', 1)
call s:initVariable('g:vorax_abort_session_warning', 0)
call s:initVariable('g:vorax_limit_rows_warning', 0)

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

" The format for xplan
call s:initVariable('g:vorax_xplan_format', 'ALLSTATS LAST')

" The size of the error window
call s:initVariable('g:vorax_errwin_height', 5)
call s:initVariable('g:vorax_errwin_goto_first', 1)

" Settings related to folding
call s:initVariable('g:vorax_folding_enable', 1)
" The initial state can be:
"   all_closed = all folds are initially closed
"   all_open = all folds are initially openned
call s:initVariable('g:vorax_folding_initial_state', 'all_open')

" Settings related to connection profiles
" where to open the cmanager: right, left
call s:initVariable('g:vorax_cmanager_side', 'right')
" the size of the cmanager window
call s:initVariable('g:vorax_cmanager_size', 30)

" Whenever or not to display a warning when about to edit a db object.
" two cases: 
"   1. VORAXEdit an object and a file matching the object name and type
"   already exists. An warning will inform that just the file was open
"   and not the actual source from the database.
"
"   2. VORAXEdit! an object and a file matching the object name and type
"   already exists. An warning will inform that the local file content
"   was replaced with the actual source from the database.
call s:initVariable('g:vorax_edit_warning', 1)
call s:initVariable('g:vorax_dbexplorer_exclude', '')
call s:initVariable('g:vorax_dbexplorer_force_edit', 0)
" where to open the db explorer: right, left
call s:initVariable('g:vorax_dbexplorer_side', 'left')
" the size of the db explorer window
call s:initVariable('g:vorax_dbexplorer_size', 30)

" the hash key is the object_type from DBMS_METADATA
call s:initVariable('g:vorax_plsql_associations',
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
exe 'autocmd BufRead,BufNewFile *.{' . join(values(g:vorax_plsql_associations), ',') . '} let &ft="sql" | SQLSetType plsqlvorax'

call s:initVariable('g:vorax_sql_script_default_extension', 'sql')
call s:initVariable('g:vorax_sql_associations',
      \ {'TABLE' : 'tab',
      \  'VIEW' : 'viw',
      \  'SQL_DEFAULT' : g:vorax_sql_script_default_extension})
exe 'autocmd BufRead,BufNewFile *.{' . join(values(g:vorax_sql_associations), ',') . '} let &ft="sql" | SQLSetType sqlvorax'

" Oradoc selective books
call s:initVariable('g:vorax_oradoc_index_only', [
      \ "Database SQL Language Reference",
      \ "Database Reference",
      \ "Database PL/SQL Packages and Types Reference",
      \ "Database Error Messages"])
call s:initVariable('g:vorax_oradoc_max_results', 30)
call s:initVariable('g:vorax_oradoc_win_style', 'horizontal')
call s:initVariable('g:vorax_oradoc_win_side', 'top')
call s:initVariable('g:vorax_oradoc_win_size', 5)
" }}}

" Commands {{{

command! -n=1 VORAXConnect :call vorax#sqlplus#Connect(<q-args>)
command! -n=1 VORAXExec :call vorax#sqlplus#Exec(<q-args>)
command! -n=0 VORAXOutputToggle :call vorax#output#Toggle()
command! -n=+ -bang -complete=customlist,vorax#explorer#OpenDbComplete VORAXEdit :call vorax#explorer#OpenDbObject('<bang>', <f-args>)
command! -n=1 -bang -complete=customlist,vorax#toolkit#DescComplete VORAXDesc :call vorax#toolkit#Desc(<q-args>, '<bang>')
command! -n=0 VORAXConnectionsToggle :call vorax#cmanager#Toggle()
command! -n=0 VORAXExplorerToggle :call vorax#explorer#Toggle()
command! -n=0 VORAXScratch :call vorax#toolkit#NewSqlScratch()
command! -n=1 -complete=file VORAXDocBooks :call vorax#oradoc#Books(<q-args>)
command! -n=1 -complete=file VORAXDocIndex :call vorax#oradoc#CreateIndex(<q-args>)
command! -n=* -complete=file VORAXDocSearch :call vorax#oradoc#Search(<f-args>)

" }}}

" Key mappings {{{

if g:vorax_map_keys
  " global mappings
  nnoremap <silent> <Leader>o :VORAXOutputToggle<CR>
  nnoremap <silent> <Leader>pr :VORAXConnectionsToggle<CR>
  nnoremap <silent> <Leader>ve :VORAXExplorerToggle<CR>
  nnoremap <silent> <Leader>ss :VORAXScratch<CR>
  nnoremap <silent> <Leader>k :VORAXDocSearch<CR>
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
