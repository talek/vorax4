" File:        voraxlib/toolkit.vim
" Author:      Alexandru Tică
" Description: Provides common Vorax features.
" License:     see LICENSE.txt

function! vorax#toolkit#DescComplete(arglead, cmdline, crrpos) "{{{
	let parts = split(strpart(a:cmdline, 0, a:crrpos), '\s\+', 1)
	if len(parts) == 2
		" completion for object name
		let lead_parts = split(a:arglead, '\.', 1)
		if len(lead_parts) > 1
			let owner = lead_parts[0]
			let prefix = lead_parts[1]
		else
			let owner = ''
			let prefix = a:arglead
		endif
		let output = vorax#sqlplus#RunVoraxScript('get_obj4desc.sql',
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

function! vorax#toolkit#Desc(name, verbose) abort "{{{
  if !vorax#utils#IsEmpty(a:name)
		" the name must be resolved first
		let metadata = vorax#sqlplus#NameResolve(a:name)
		if a:verbose == '!'
			if metadata['type'] ==? 'TABLE'
				let output = vorax#sqlplus#RunVoraxScript('verbose_desc.sql', 
							\ metadata['schema'],
							\	metadata['object'])
			else
				redraw
				call vorax#utils#SpitWarn('Sorry, VORAXDesc! is supported for TABLEs only!')
				return
			endif
		else
			let output = vorax#sqlplus#RunVoraxScript('simple_desc.sql', 
						\ metadata['schema'] . '.' . metadata['object'])
		endif
		call vorax#output#SpitAll(output)
	endif
endfunction "}}}

function! vorax#toolkit#DescUnderCursor(verbose) abort "{{{
	let current_line = getline('.')
	let pos_in_line = col('.') - 1
	let crr_identifier = vorax#ruby#IdentifierAt(current_line, pos_in_line)
	call vorax#toolkit#Desc(crr_identifier, a:verbose)
endfunction "}}}

function! vorax#toolkit#InitCommonBuffers() abort
	command! -n=0 -buffer -bang VORAXDescUnderCursor :call vorax#toolkit#DescUnderCursor('<bang>')
	if g:vorax_map_keys
		nnoremap <buffer> <silent> <Leader>d :VORAXDescUnderCursor<CR>
		nnoremap <buffer> <silent> <Leader>D :VORAXDescUnderCursor!<CR>
	endif
endfunction