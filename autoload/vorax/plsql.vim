" File:        autoload/vorax/plsql.vim
" Author:      Alexandru Tică
" Description: Provides utilities for plsql buffers.
" License:     see LICENSE.txt

let s:plsql_struct_key = 'plsql_buffer_struct'
let s:sql_pack = tempname() . ".sql"

function! vorax#plsql#GotoDef() abort "{{{
  let text_code = vorax#utils#BufferContent(1, line('.'))
  let crr_pos = line2byte(line('.')) + col('.')
  call vorax#ruby#ComputePlsqlStructure(s:plsql_struct_key, text_code)
  let name = expand('<cword>')
  let local_items = vorax#ruby#LocalItems(s:plsql_struct_key, crr_pos, name)
  for item in local_items
    if (has_key(item, 'variable') && item['variable'] ==? name) ||
          \ (has_key(item, 'name') && item['name'] ==? name)
      exec item['declared_at'] . 'go'
      break
    endif
  endfor
endfunction "}}}

function! vorax#plsql#CompileCurrentBuffer() abort "{{{
  let crr_buffer = bufnr('%')
  let crr_win = winnr()
  let content = getline(1, '$')
  call writefile(content, s:sql_pack)
  let properties = vorax#sqlplus#Properties()
  let options = ['store set ' . properties['store_set'] . ' replace', 
        \ 'set markup html off', 
        \ 'set feedback on',
        \ 'set time off',
        \ 'set define off',
        \ 'set sqlprompt ""',
        \ 'set echo off',
        \ 'set timing off',
        \ 'set linesize 10000']
  let options = extend(options, properties['sane_options'])
  let prep = join(options, "\n")
  let post = "@" . properties['store_set']
  let hash = {'prep' : prep, 'post' : post, 'funnel' : 0}
  let output = vorax#sqlplus#ExecImmediate('@' . s:sql_pack, hash)
  call vorax#output#SpitAll(output)
  call s:ShowErrors(crr_buffer, crr_win)
endfunction "}}}

function! s:ShowErrors(bufnr, winnr) abort "{{{
  " figure out the structure of this buffer
  let modules = s:GetDefinedPlsqlModules()
  let errors = s:GetErrors(modules)
  let err_list = []
  for rec in errors
    let offset = s:GetOffset(modules, rec[3], rec[4], rec[5])
    let err_item = {'bufnr' : a:bufnr,
          \ 'lnum' : str2nr(rec[0]) + offset,
          \ 'col' : rec[1],
          \ 'text' : rec[2],
          \ 'type' : 'E'}
    call add(err_list, err_item)
  endfor
  call setloclist(a:winnr, err_list, 'r')
  exe a:winnr.'wincmd w'
  exe 'lwindow ' . g:vorax_errwin_height
  if g:vorax_errwin_goto_first && len(err_list) > 0
    lr
  endif
endfunction "}}}

function! s:GetOffset(modules, owner, object, type) "{{{
  call VORAXDebug('PLSQL s:GetOffset: a:modules=' . string(a:modules) . 
        \ ' a:owner=' . a:owner .
        \ ' a:object=' . a:object .
        \ ' a:type=' . a:type)
  let offset = 0
  for module in a:modules
    if substitute(module['owner'], '"', '', 'g') ==? a:owner &&
          \ substitute(module['module'], '"', '', 'g') ==? a:object &&
          \ (module['type'] == "" || module['type'] ==? a:type)
      let offset = module['defined_at'] - 1
      break
    endif
  endfor
  return offset
endfunction "}}}

function! s:GetErrors(modules) "{{{
  call VORAXDebug("PLSQL GetErrros: modules=" . string(a:modules))
  let filter = []
  for module in a:modules
    let where = "(owner = '" . substitute(module['owner'], '"', '', 'g') . "' and " .
          \ "name = '" . substitute(module['module'], '"', '', 'g') . "'"
    if !vorax#utils#IsEmpty(module['type'])
      let where .= " and type = '" . module['type'] . "')"
    else
      let where .= ")"
    endif
    call add(filter, where)
  endfor
  if len(filter) > 0
    let rs = vorax#sqlplus#Query('select line, position, text, owner, name, type ' .
          \ 'from all_errors ' .
          \ 'where ' . join(filter, ' OR ') . ';', 'Fetching errors, if any...')
    if type(rs) == 4 && has_key(rs, "resultset") && len(rs["resultset"]) >= 1
      return rs["resultset"][0]
  endif
  return []
endfunction "}}}

function! s:GetDefinedPlsqlModules() abort "{{{
  let text_code = vorax#utils#BufferContent()
  let regions = vorax#ruby#PlsqlRegions(text_code)
  let modules = []
  for region_h in regions
    if s:IsPlsqlModule(region_h)
      let name = region_h['name']
      let parts = split(name, '\m\.')
      if len(parts) == 2
        let owner = parts[0]
        let module = parts[1]
      elseif len(parts) == 1
        let module = parts[0]
        let owner = vorax#sqlplus#Properties()['user']
      endif
      if exists('owner')
        let type = s:OracleType(region_h['region_type'])
        call add(modules, {'owner' : toupper(owner),
              \ 'module' : toupper(module),
              \ 'type' : type,
              \ 'defined_at' : byte2line(region_h['start_pos']+1)})
      endif
    endif
  endfor
  return modules
endfunction "}}}

function! s:OracleType(region_type) abort "{{{
  let oratype = ''
  " just composite objects are interesting
  if a:region_type ==? 'PackageSpecRegion'
    let oratype = 'PACKAGE'
  elseif a:region_type ==? 'PackageBodyRegion'
    let oratype = 'PACKAGE BODY'
  elseif a:region_type ==? 'TypeSpecRegion'
    let oratype = 'TYPE'
  elseif a:region_type ==? 'TypeBodyRegion'
    let oratype = 'TYPE BODY'
  endif
  return oratype
endfunction "}}}

function! s:IsPlsqlModule(region_h) abort "{{{
  " TODO: handle triggers as well
  if a:region_h['level'] == 1 &&
        \ (a:region_h['region_type'] ==? 'PackageSpecRegion' ||
        \  a:region_h['region_type'] ==? 'PackageBodyRegion' ||
        \  a:region_h['region_type'] ==? 'TypeSpecRegion' ||
        \  a:region_h['region_type'] ==? 'TypeBodyRegion' ||
        \  a:region_h['region_type'] ==? 'SubprogRegion')
    return 1
  else
    return 0
  endif
endfunction "}}}

