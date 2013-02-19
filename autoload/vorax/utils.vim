" File:        voraxlib/utils.vim
" Author:      Alexandru Tică
" Description: Various helper functions.
" License:     see LICENSE.txt

let s:throbber = {'elements' : g:vorax_throbber, 'index' : 0}

function! vorax#utils#CurrentSelection() abort"{{{
  let reg_ = [@", getregtype('"')]
  let regA = [@a, getregtype('a')]
  if mode() =~# "[vV\<C-v>]"
    silent normal! "aygv
  else
    let pos = getpos('.')
    silent normal! gv"ay
    call setpos('.', pos)
  endif
  let text = @a
  call setreg('"', reg_[0], reg_[1])
  call setreg('a', regA[0], regA[1])
  return text
endfunction"}}}

function! vorax#utils#DescribeCurrentStatement(plsql_blocks, sqlplus_commands) abort"{{{
  let line = line('.')
  let col = col('.')
  let position = vorax#utils#AbsolutePosition(line, col)
  let text = vorax#utils#BufferContent(s:ParseOffset(line, col))
  let stmt = vorax#ruby#CurrentStatement(text, position, a:plsql_blocks, a:sqlplus_commands)
  call VORAXDebug('vorax#utils#DescribeCurrentStatement: crr_statement=' . string(stmt))
  let stmt['relative'] = position - stmt['position']
  return stmt
endfunction"}}}

function! vorax#utils#CurrentStatement(plsql_blocks, sqlplus_commands) abort"{{{
  let stmt = vorax#utils#DescribeCurrentStatement(a:plsql_blocks, a:sqlplus_commands)
  return stmt['text']
endfunction"}}}

function! vorax#utils#AbsolutePosition(line, column) abort"{{{
  if g:vorax_parse_min_lines > 0
    let offset = a:line - g:vorax_parse_min_lines
    if offset > 0
      let current_position = line2byte(a:line) - line2byte(offset)
    else
      let current_position = line2byte(a:line)
    endif
  else
    let current_position = line2byte(a:line)
  endif
  return current_position + a:column - 1
endfunction"}}}

function! vorax#utils#IsVoraxBuffer() abort"{{{
  return (&ft == 'sql' || &ft == 'plsql')
endfunction"}}}

function! vorax#utils#Throbber() abort "{{{
  if len(s:throbber['elements']) == 0
    return ""
  endif
  if s:throbber['index'] < len(s:throbber['elements']) - 1
    let s:throbber['index'] += 1
  else
    let s:throbber['index'] = 0
  end
  return s:throbber['elements'][s:throbber['index']]
endfunction "}}}

function! vorax#utils#SpitWarn(str)"{{{
  echohl ErrorMsg
  echo a:str
  echohl None
  let v:warningmsg = a:str
endfunction"}}}

function! vorax#utils#Strip(str)"{{{
  return substitute(a:str, '^\_s*\(.\{-}\)\_s*\_$', '\1', '')
endfunction"}}}

function! vorax#utils#ClearUserInputStream() abort"{{{
  while 1
    if getchar(0) == 0
      break
    endif
  endwhile
endfunction"}}}

function! vorax#utils#BufferContent(...) abort"{{{
	let end_with = '$'
  if exists('a:1')
  	let start_with = a:1
  	if exists('a:2')
			let end_with = a:2
		endif
  else
  	let start_with = 1
  endif
  if &ff == 'dos'
    let separator = "\r\n"
  elseif &ff == 'unix'
    let separator = "\n"
  elseif &ff == 'mac'
    let separator = "\r"
  endif
	let content = join(getline(start_with, end_with), separator)
  return content
endfunction"}}}

function! vorax#utils#VimCmdOutput(cmd) abort"{{{
  redir => output
  silent execute a:cmd
  redir END
  return output
endfunction"}}}

function! vorax#utils#CompareRegionsByLevelDesc(i1, i2)"{{{
	let i1 = a:i1.level
	let i2 = a:i2.level
	return i1 == i2 ? 0 : i1 < i2 ? 1 : -1
endfunction"}}}

function! vorax#utils#GetTopRegion(descriptor, position)
  for code_region in a:descriptor
		if (code_region["start_pos"] < a:position) && 
					\ (code_region["end_pos"] > a:position) &&
					\ (code_region["level"] == 1)
      return code_region
		endif
	endfor
	return {}
endfunction

function! vorax#utils#GetCurrentRegion(descriptor, position, ...)
  " the current region depends on the way the descriptor is sorted. If the
  " most inner region is to be returned, then it has to be sorted DESC by
  " level
  for code_region in a:descriptor
		if (code_region["start_pos"] < a:position) && (code_region["end_pos"] > a:position)
      if exists('a:1') 
      	if code_region["type"] =~? a:1
					return code_region
				endif
			else
				return code_region
			endif
		endif
	endfor
	return {}
endfunction

function! vorax#utils#GetSpecRegion(descriptor, name)
  for code_region in a:descriptor
		if code_region["name"] ==? a:name && code_region["type"] ==? 'SPEC'
      return code_region
		endif
	endfor
	return {}
endfunction

function! vorax#utils#GetDirectSubRegions(descriptor, region)
	let result = []
	for code_region in a:descriptor
		if (code_region["level"] == a:region["level"] + 1) &&
					\ (code_region["start_pos"] > a:region["start_pos"]) &&
					\ (code_region["end_pos"] < a:region["end_pos"])
			call add(result, code_region)
		endif
	endfor
	return result
endfunction

function! s:ParseOffset(line, column) abort"{{{
  if g:vorax_parse_min_lines > 0
    let offset = a:line - g:vorax_parse_min_lines
    if offset > 0
      return offset
    endif
  endif
  return 0
endfunction"}}}

