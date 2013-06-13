" File:        autoload/vorax/explorer.vim
" Author:      Alexandru Tică
" Description: Provides DB object explore features.
" License:     see LICENSE.txt

let s:object_types = ['FUNCTION', 'PROCEDURE', 'TRIGGER',
			\ 'PACKAGE', 'PACKAGE_SPEC', 'PACKAGE_BODY',
			\ 'TYPE', 'TYPE_SPEC', 'TYPE_BODY',
			\ 'JAVA_SOURCE', 'TABLE', 'VIEW', 'MATERIALIZED_VIEW',
			\ 'SEQUENCE', 'SYNONYM', 'USER']

function! vorax#explorer#OpenDbComplete(arglead, cmdline, crrpos) "{{{
	let parts = split(strpart(a:cmdline, 0, a:crrpos), '\s\+', 1)
	if len(parts) == 2
		" completion for object type
		return filter(copy(s:object_types), "v:val =~? '^" . a:arglead . "'")
	elseif len(parts) == 3
		" completion for object name
		let object_type = s:DbmsMetadata2AllObjects(parts[1])
		let lead_parts = split(a:arglead, '\.', 1)
		if len(lead_parts) > 1
			let owner = lead_parts[0]
			let prefix = lead_parts[1]
		else
			let owner = ''
			let prefix = a:arglead
		endif
		let output = vorax#sqlplus#RunVoraxScript('get_objects.sql',
					\ toupper(object_type),
					\ toupper(owner),
          \ toupper(prefix))
		let data  = vorax#ruby#ParseResultset(output)
		let result = []
		if exists('data["resultset"][0]')
			let rs = data["resultset"][0]
			for rec in rs
				call add(result, rec[0])
			endfor
			return result
		endif
	endif
endfunction "}}}

function! vorax#explorer#OpenDbObject(bang, ...) "{{{
	" expect the first parameter to be the object type and
	" the second the object name (possibly including the owner)
	if a:0 == 2
		let name = a:2
		" the type is stored in DBMS_METADATA style but the
		" lookup is done in ALL_OBJECTS
		let type = toupper(a:1)
	else
		" not enough params
		return
	endif
	let parts = split(name, '\.')
	if len(parts) == 2
    let owner = parts[0]
    let object_name = parts[1]
	else
		let owner = ''
		let object_name = name
	endif
	" compute the buffer/file name
	let file_name = s:BufferName(type, object_name)
	if a:bang == ""
	  if a:bang == "" && filereadable(file_name)
			call s:OpenVoraxBuffer(file_name)
			call vorax#utils#SpitInfo("The local file was openned for edit not " . 
						\ "the definition from the database!")
			return
		endif
	endif
	let output = vorax#sqlplus#RunVoraxScript('extract_def.sql',
				\ toupper(owner),
				\ toupper(object_name),
				\ type)
	let data  = vorax#ruby#ParseResultset(output)
	if exists('data["resultset"][0]')
		let rs = data["resultset"][0]
		" expect one record only
		if exists('rs[0][0]')
			call s:OpenVoraxBuffer(file_name)
			if a:bang == "!"
				" clear the buffer content
				normal! gg"_dG
				if g:vorax_edit_warning && filereadable(file_name)
					redraw
					call vorax#utils#SpitInfo("A local file matching the DB object name was found!\n" .
								\ "It was overwritten with the definition from the database!\n" .
								\ "Take care before saving the buffer!")
				endif
			endif
			call append(0, split(rs[0][0], '\n'))
		endif
	endif
endfunction "}}}

function! s:OpenVoraxBuffer(file_name) "{{{
	" find a suitable window to stack upon to
	call s:FocusCandidateWindow()
	" open the file
	silent! exe 'edit ' . a:file_name
endfunction "}}}

function! s:DbmsMetadata2AllObjects(type) "{{{
	let type = a:type
	if type =~? '^PACKAGE_.*'
		let type = 'PACKAGE'
	elseif type =~? '^TYPE_.*'
		let type = 'TYPE'
	else
		let type = substitute(type, '_', ' ', 'g')
	endif
	return type
endfunction "}}}

function! s:BufferName(type, name) "{{{
	" is it a plsql object?
	let file_ext = get(g:vorax_plsql_associations, a:type, '')
	if vorax#utils#IsEmpty(file_ext)
		" it's a SQL buffer then
		let file_ext = get(g:vorax_sql_associations, a:type, g:vorax_sql_script_default_extension)
	endif
	return a:name . '.' . file_ext
endfunction "}}}

function! s:FocusCandidateWindow() "{{{
  let winlist = []
  " iterate through all windows and get info from them
  windo let winlist += [[winnr(), &buftype]]
  for w in winlist
    if w[1] == "" || w[1] == "nofile"
      " great! we just found a suitable window... focus it please
      exe w[0] . 'wincmd w'
      return
    endif
  endfor
endfunction "}}}
