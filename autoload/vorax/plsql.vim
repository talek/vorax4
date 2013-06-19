" File:        autoload/vorax/plsql.vim
" Author:      Alexandru Tică
" Description: Provides utilities for plsql buffers.
" License:     see LICENSE.txt

let s:plsql_struct_key = 'plsql_buffer_struct'

function! vorax#plsql#GotoDef()
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
endfunction
