" File:        autoload/vorax/sqlplus.vim
" Author:      Alexandru Tică
" Description: Provides Sqlplus integration/glue.
" License:     see LICENSE.txt

" Create the buddy sqlplus process. It is important to have it
" initialized earlier, just in case someone will try to invoke
" a sqlplus connect command directly, not via VORAXConnect.
call vorax#ruby#SqlplusFork()

" Internal Properties {{{

let s:script_dir = expand('<sfile>:p:h')
let s:properties = {'store_set'     : tempname() . ".opts",
                  \ 'sql_pack'      : tempname() . ".sql",
                  \ 'user'          : '',
                  \ 'db'            : '',
                  \ 'privilege'     : '',
                  \ 'connstr'       : '',
                  \ 'sql_folder'    : fnamemodify(expand('<sfile>:p:h') . '/../../vorax/sql/', ':p:8'),
                  \ 'db_banner'     : '',
                  \ 'cols_clear'    : '',
                  \ 'sane_options'  : ['set define "&"',
                  \                    'set pause off',
                  \                    'set termout on']}

function! vorax#sqlplus#Properties()
  return s:properties
endfunction

" }}}

" Connection logic {{{

function! vorax#sqlplus#Connect(cstr) abort "{{{
  call VORAXDebug("vorax#sqlplus#Connect: cstr=" . string(a:cstr))
  let parts = s:PrepareCstr(a:cstr)
  " run BeforeConnect hook
  if exists('*VORAXBeforeConnect')
    " Execute hook
    call VORAXBeforeConnect(parts['user'], parts['db'], parts['role'])
  endif
  " visual feedback to the user please
  redraw
  echo 'Initializing connection...'
  " theoretically we have the buddy sqlplus process, but it is a
  " good idea to recreate it here, as a last resort just in case that
  " sqlplus process is hung or other nasty things had happen with it
  call vorax#sqlplus#Initialize()
  let prep = extend(['set echo off', 'set sqlprompt ""', 'set time off'],
              \ s:properties['sane_options'])
  let post = vorax#sqlplus#GatherStoreSetOption('echo', 'sqlprompt', 
        \ 'time', 'pause', 'define', 'termout')
  let s:properties['connstr'] = vorax#sqlplus#MergeCstr(parts)
  call vorax#ruby#SqlplusExec("connect " . s:properties['connstr'],
        \ {'prep': join(prep, "\n"), 'post' : post})
  let output = ""
  while vorax#ruby#SqlplusBusy()
    let output .= vorax#ruby#SqlplusReadOutput()
    " visual feedback to the user please
    echo 'Connecting...' . vorax#utils#Throbber()
    redraw
    sleep 50m
  endwhile
  if !g:vorax_output_window_append
    call vorax#output#Clear()
  endif
  call vorax#output#Spit(vorax#utils#Strip(output))
  call vorax#sqlplus#UpdateSessionOwner()
  call s:PrintWelcomeBanner()
  " clear the throbber message
  echom ""
  " reset the omni cache
  call vorax#omni#ResetCache()
  " refresh dbexplorer
  call vorax#explorer#RefreshRoot()
  redraw
  " run AfterConnect hook
  if exists('*VORAXAfterConnect')
    " Execute hook
    call VORAXAfterConnect(s:properties['user'], s:properties['db'], s:properties['privilege'])
  endif
endfunction "}}}

function! vorax#sqlplus#Initialize() abort "{{{
  call VORAXDebug("vorax#sqlplus#Initialize()...")
  call vorax#ruby#SqlplusFork()
  sleep 300m " just let sqlplus to warm up
  let opts = add(g:vorax_sqlplus_options, 
        \ 'store set ' . s:properties['store_set'] . ' replace')
  let opts = extend(opts, s:properties['sane_options'])
  call vorax#sqlplus#ExecImmediate(join(opts, "\n"))
  call VORAXDebug("vorax#sqlplus#Initialize(): done!")
endfunction "}}}

function! vorax#sqlplus#UpdateSessionOwner() "{{{
  if g:vorax_update_session_owner
    if vorax#ruby#SqlplusIsInitialized() &&
          \ vorax#ruby#SqlplusIsAlive()
      let vars = vorax#sqlplus#DefinedVariable(
            \ '_USER', 
            \ '_CONNECT_IDENTIFIER', 
            \ '_O_VERSION', 
            \ '_PRIVILEGE')
      call VORAXDebug("vorax#sqlplus#UpdateSessionOwner vars=" . string(vars))
      if vars['_USER'] != ""
        let s:properties['user'] = vars['_USER']
        let s:properties['db'] = vars['_CONNECT_IDENTIFIER']
        let s:properties['privilege'] = vars['_PRIVILEGE']
        let s:properties['db_banner'] = vars['_O_VERSION']
        call VORAXDebug("vorax#sqlplus#UpdateSessionOwner s:properties=" . string(s:properties))
        " update status bar
        let &ro = &ro
        return
      endif
    endif
    let s:properties['user'] = ''
    let s:properties['db'] = ''
    let s:properties['privilege'] = ''
    let s:properties['db_banner'] = ''
    call VORAXDebug("vorax#sqlplus#UpdateSessionOwner s:properties=" . string(s:properties))
    " update status bar
    let &ro = &ro
  endif
endfunction "}}}

function! s:PrintWelcomeBanner() abort "{{{
  if s:properties['user'] != ""
    let banner = s:properties['db_banner'] .
          \ "\n\n" .
          \ "Logged in as: " . 
          \ s:properties['user'] . 
          \ '@' . 
          \ s:properties['db'] .
          \ (s:properties['privilege'] != '' ? " " . s:properties['privilege'] : "")
    call vorax#output#Spit("\n\n" . banner . "\n")
  endif
endfunction "}}}

function! s:PrepareCstr(cstr) abort "{{{
  let cstr = a:cstr
  while 1
    let parts = vorax#ruby#ParseConnectionString(cstr)
    call VORAXDebug(parts)
    if parts.prompt_for == ''
      break
    elseif parts.prompt_for == 'user'
      let cstr = input("Username: ")
    elseif parts.prompt_for == 'password'
      let parts['password'] = inputsecret("Password: ")
      let cstr = vorax#sqlplus#MergeCstr(parts)
    endif
  endwhile
  return parts
endfunction "}}}

function! vorax#sqlplus#MergeCstr(parts) "{{{
    return a:parts["user"] . 
          \ "/" . a:parts["password"] .
          \ (a:parts["db"] == "" ? "" : "@" . a:parts["db"]) . 
          \ (a:parts["role"] == "" ? "" : " as " .a:parts["role"])
endfunction "}}}

" }}}

" Sqlplus baby {{{

function! vorax#sqlplus#Exec(command, ...) abort "{{{
  let pre = ""
  let post = ""
  let command = a:command
  let hash = {'pack_file' : s:properties['sql_pack'],
        \ 'funnel' : vorax#output#GetFunnel()}
  if exists("a:1") && type(a:1) == 4 "dictionary please
    let hash = a:1
  endif
  try
    if command =~ '\m^\s*$'
      " just an empty string... fuck it!
      return
    end
    if exists('g:vorax_limit_rows')
      let command = s:LimitRows(command, g:vorax_limit_rows)
    endif
    if g:vorax_output_full_heading
      let format_cols = s:FormatColumns(command)
      if has_key(hash, 'prep')
        let hash['prep'] .= "\n" . format_cols['format']
      else
        let hash['prep'] = format_cols['format']
      endif
      if has_key(hash, 'post')
        let hash['post'] .= "\n" . format_cols['clear']
      else
        let hash['post'] = format_cols['clear']
      endif
      " need to save them in this global namespace in order
      " to cleanup if the query is cancelled
      let s:properties['cols_clear'] = format_cols['clear']
    else
      let s:properties['cols_clear'] = ''
    endif
    let stmt = vorax#ruby#PrepareExec(command)
    call vorax#ruby#SqlplusExec(stmt, hash)
    if vorax#ruby#SqlplusIsInitialized() && vorax#ruby#SqlplusIsAlive()
      call vorax#output#SpitterStart()
    endif
  catch /^VRX-01/
    call VORAXDebug("vorax#sqlplus#Exec: no Sqlplus process running.")
    call vorax#utils#SpitWarn("There\'s no SqlPlus process running. Did you connect first?")
  catch /^VRX-02/
    call vorax#sqlplus#WarnCrash()
  endtry
endfunction "}}}

function! vorax#sqlplus#ExecImmediate(command, ...) abort "{{{
  let pre = ""
  let post = ""
  let hash = {'pack_file' : s:properties['sql_pack']}
  if exists("a:1") && type(a:1) == 4 "dictionary please
    let hash = a:1
  endif
  if !exists('hash["funnel"]')
    let hash['funnel'] = vorax#output#GetFunnel()
  endif
  try
    call vorax#ruby#SqlplusExec(a:command, hash)
    let output = ""
    if has_key(hash, 'message')
      let message = hash['message']
    else
      let message = 'Busy...'
    endif
    while vorax#ruby#SqlplusBusy()
      let output .= vorax#ruby#SqlplusReadOutput()
      echo message . ' ' . vorax#utils#Throbber()
      redraw
    endwhile
    echo 'Done.'
    return output
  catch /^VRX-01/
    call VORAXDebug("vorax#sqlplus#Exec: no Sqlplus process running.")
    call vorax#utils#SpitWarn("There\'s no SqlPlus process running. Did you connect first?")
  catch /^VRX-02/
    call vorax#sqlplus#WarnCrash()
  endtry
endfunction "}}}

function! vorax#sqlplus#Query(command, ...) abort "{{{
  call VORAXDebug("vorax#sqlplus#Query command=" . string(a:command))
  let prep = join(extend(['store set ' . s:properties['store_set'] . ' replace', 'set markup html on', 'set linesize 10000'],
              \ s:properties['sane_options']), "\n")
  let post = "@" . s:properties['store_set']
  let hash = {'prep' : prep, 'post' : post, 'funnel' : 0}
  if exists('a:1')
    let hash['message'] = a:1
  endif
  let output = vorax#sqlplus#ExecImmediate(a:command, hash)
  return vorax#ruby#ParseResultset(output)
endfunction "}}}

function! vorax#sqlplus#DefinedVariable(...) abort "{{{
  call VORAXDebug("vorax#sqlplus#DefinedVariable: " . string(a:000))
  let pre = extend(
        \ ['store set ' . s:properties['store_set'] . ' replace'],
        \ s:properties['sane_options'])
  call vorax#sqlplus#ExecImmediate(join(pre, "\n"))
  call VORAXDebug('vorax#sqlplus#DefinedVariable: sp_options='.string(readfile(s:properties['store_set'], 'b')))
  let post = vorax#sqlplus#GatherStoreSetOption('pause', 'define', 'termout')
  call vorax#ruby#SqlplusExec("define", {'post' : post})
  let output = ""
  while vorax#ruby#SqlplusBusy()
    let output .= vorax#ruby#SqlplusReadOutput()
  endwhile
  call VORAXDebug("vorax#sqlplus#DefinedVariable: output=" . string(output))
  let result = {}
  for var in a:000
    let match = matchlist(output, '\%(^\|\n\)DEFINE ' . var . '\s\+= "\(\_.\{-\}\)"')
    if len(match) >= 1
      let result[var] = match[1]
    else
      let result[var] = ""
    endif
  endfor
  return result
endfunction "}}}

function! vorax#sqlplus#SessionOwner() abort "{{{
  return s:properties['user'] . '@' .
        \ s:properties['db'] .
        \ (s:properties['privilege'] != "" ? 
            \ ' ' . s:properties['privilege'] : 
            \ '')
endfunction "}}}

function! vorax#sqlplus#GatherStoreSetOption(...) "{{{
  let options = readfile(s:properties['store_set'])
  let multi_line = 0
  let optionset = ""
  for line in options
    for option_name in a:000
      if !multi_line 
        if line =~ '^set ' . option_name
          let optionset .= line . "\n"
          let multi_line = (line =~ '-$' ? 1 : 0)
          break
        endif
      else
        let optionset .= line . "\n"
        let multi_line = (line =~ '-$' ? 1 : 0)
      endif
    endfor
  endfor
  return optionset
endfunction "}}}

function! vorax#sqlplus#WarnCrash() abort "{{{
  call VORAXDebug("vorax#sqlplus#WarnCrash: SqlPlus process has unexpectedly died!")
  call vorax#utils#SpitWarn("The buddy SqlPlus process has unexpectedly died! You should :VORAXConnect again!")
endfunction "}}}

function! vorax#sqlplus#SandboxExec(cmd) "{{{
  let prep = 'store set ' . s:properties['store_set'] . ' replace' . "\nset echo off"
  let post = "@" . s:properties['store_set']
  let hash = {'prep' : prep, 'post' : post, 'funnel' : 0, 'pack_file' : s:properties['sql_pack']}
  call vorax#sqlplus#Exec(a:cmd, hash)
endfunction "}}}

function! vorax#sqlplus#PrepareVoraxScript(name, params) "{{{
  let prep = 'store set ' . s:properties['store_set'] . ' replace' . "\nset echo off"
  let post = "@" . s:properties['store_set']
  let hash = {'prep' : prep, 'post' : post, 'funnel' : 0, 'pack_file' : s:properties['sql_pack']}
  let params = ''
  for param in a:params
    let params .= vorax#sqlplus#QuoteScriptParam(param) . ' '
  endfor
  let script = s:properties['sql_folder'] . a:name . ' ' . params
  return {'script': script, 'hash': hash}
endfunction "}}}

function! vorax#sqlplus#RunVoraxScript(name, ...) abort "{{{
  call VORAXDebug("vorax#sqlplus#RunVoraxScript name=" . a:name)
  let handler = vorax#sqlplus#PrepareVoraxScript(a:name, a:000)
  let output = vorax#sqlplus#ExecImmediate('@' . handler.script, handler.hash)
  call VORAXDebug("vorax#sqlplus#RunVoraxScript output=" . output)
  return output
endfunction "}}}

function! vorax#sqlplus#RunVoraxScriptBg(name, ...) abort "{{{
  call VORAXDebug("vorax#sqlplus#RunVoraxScriptBg name=" . a:name)
  let handler = vorax#sqlplus#PrepareVoraxScript(a:name, a:000)
  call vorax#sqlplus#Exec('@' . handler.script, handler.hash)
endfunction "}}}

function! vorax#sqlplus#NameResolve(name) abort "{{{
  call VORAXDebug("vorax#sqlplus#NameResolve name=" . a:name)
  let resolve_data = {'schema' : '', 'object' : '', 'type' : '', 'extra' : '', 'id' : ''}
  let output = vorax#sqlplus#RunVoraxScript('name_resolve.sql', a:name)
  let result  = vorax#ruby#ParseResultset(output)
  call VORAXDebug("vorax#sqlplus#NameResolve result=" . string(result))
  if exists('result["resultset"][0][0][0]')
    let resolve_data['schema'] = result["resultset"][0][0][0]
    let resolve_data['object'] = result["resultset"][0][0][1]
    let resolve_data['type'] = result["resultset"][0][0][2]
    let resolve_data['id'] = result["resultset"][0][0][3]
    let resolve_data['extra'] = result["resultset"][0][0][4]
  endif
  call VORAXDebug("vorax#sqlplus#NameResolve resolve_data=" . string(resolve_data))
  return resolve_data
endfunction "}}}

function! vorax#sqlplus#QuoteScriptParam(param) abort "{{{
  let param = substitute(a:param, "'", "''", 'g')
  return "'" . param . "'"
endfunction "}}}

function! vorax#sqlplus#GetSource(owner, object, type) abort "{{{
  let output = vorax#sqlplus#RunVoraxScript('get_source.sql', a:owner, a:object, a:type)
  let data  = vorax#ruby#ParseResultset(output)
  let content = ''
  if exists('data["resultset"][0]')
    let rs = data["resultset"][0]
    for rec in rs
      let content .= rec[0] . "\n"
    endfor
  endif
  return content
endfunction "}}}

" }}}

function! s:LimitRows(script, limit) "{{{
  let stmts = vorax#ruby#SqlStatements(a:script, 1, 1)
  let new_stmts = []
  for stmt in stmts
    let query = vorax#ruby#RemoveAllComments(stmt)
    if query =~ '\m\c^\_s*\(SELECT\|WITH\)'
      " get rid of the last terminator
      let query = substitute(query, '\m\_s*\(;\|\/\)\_s*$', '', 'g')
      " remove leading CRs
      let query = substitute(query, '\m^\_s*', '', 'g')
      let query = "select * from (\n" .
            \ '/* start original query */' .
            \ "\n" . query . "\n" .
            \ '/* end */' .
            \ "\n) where rownum <= " . a:limit . ";"
      call add(new_stmts, query)
      if g:vorax_limit_rows_warning
        call add(new_stmts, "prompt WARN: output limited to maximum " . 
              \ a:limit . " records...")
      endif
    else
      call add(new_stmts, stmt)
    end
  endfor
  return join(new_stmts, "\n")
endfunction "}}}

function! s:FormatColumns(script) "{{{
  let stmts = vorax#ruby#SqlStatements(a:script, 1, 1)
  let column_format = ""
  let column_clear = ""
  for stmt in stmts
    let query = vorax#ruby#RemoveAllComments(stmt)
    if query =~ '\m\c^\_s*\(SELECT\|WITH\)'
      for column in s:ColumnsLayout(query)
        let column_format .= "column " . column[0] .
              \ " format a" . column[1] . "\n"
        let column_clear .= "column " . column[0] .
              \ " clear" . "\n"
      endfor
    end
  endfor
  return {'format': column_format, 'clear': column_clear}
endfunction "}}}

function! s:ColumnsLayout(query) "{{{
  " get rid of the last terminator
  let query = substitute(a:query, '\m\_s*\(;\|\/\)\_s*$', '', 'g')
  " compose the statement init template
  let stmt_init = ""
  let index = 1
  for line in split(query, "\n")
    let stmt_init .= "l_stmt(" . index . ") := '" . 
          \ substitute(line, "'", "''", 'g') . 
          \ "';\n"
    let index += 1
  endfor
  " get the format columns script
  let script_content = s:ColumnsLayoutScript()
  if !vorax#utils#IsEmpty(script_content)
    let prep = 'store set ' . s:properties['store_set'] . ' replace' . "\nset echo off"
    let post = "@" . s:properties['store_set']
    let hash = {'prep' : prep, 'post' : post, 'funnel' : 0, 'pack_file' : s:properties['sql_pack']}
    let exec_code=substitute(script_content, '\m\s*-- l_stmt initialize\s*', 
          \ stmt_init,
          \ '')
    let output=vorax#sqlplus#ExecImmediate(exec_code, hash)
    let result  = vorax#ruby#ParseResultset(output)
    if exists("result['resultset'][0]")
      return result['resultset'][0]
    endif
  endif
  return []
endfunction "}}}

function! s:ColumnsLayoutScript() "{{{
  if exists('s:cl_script_content')
    return copy(s:cl_script_content)
  else
    let script_name = s:properties['sql_folder'] . 'columns_layout.sql' 
    if filereadable(script_name)
      let s:cl_script_content = join(readfile(script_name), "\n")
    endif
  endif
  return ""
endfunction "}}}
