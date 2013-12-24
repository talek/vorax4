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

function! vorax#utils#SpitInfo(str) "{{{
  echohl Question | echon "INFO: " | echohl None | echon a:str
endfunction "}}}

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
  let i1 = a:i1['level']
  let i2 = a:i2['level']
  return i1 == i2 ? 0 : i1 < i2 ? 1 : -1
endfunction"}}}

function! vorax#utils#GetTopRegion(descriptor, position)"{{{
  for code_region in a:descriptor
    if (code_region["start_pos"] < a:position) && 
          \ (code_region["end_pos"] > a:position) &&
          \ (code_region["level"] == 1)
      return code_region
    endif
  endfor
  return {}
endfunction"}}}

function! vorax#utils#RemoveDirectSubRegions(code_source, descriptor, crr_region)"{{{
  let code_source = a:code_source
  let subregions = vorax#utils#GetDirectSubRegions(a:descriptor, a:crr_region)
  let offset = 0
  for subregion in subregions
    " remove from source
    let start_region = subregion['start_pos'] - a:crr_region['start_pos'] - offset
    let end_region = subregion['end_pos'] - a:crr_region['start_pos'] + 1 - offset
    let code_source = strpart(code_source, 0, start_region) .
          \ strpart(code_source, end_region )
    let offset += (end_region - start_region)
  endfor
  return code_source
endfunction"}}}

function! vorax#utils#GetUpperRegion(descriptor, region, ...)"{{{
  " the current region depends on the way the descriptor is sorted. If the
  " most inner region is to be returned, then it has to be sorted DESC by
  " level
  for code_region in a:descriptor
    if (code_region["start_pos"] < a:region["start_pos"]) && (code_region["end_pos"] > a:region["end_pos"]) &&
          \ (code_region["level"] < a:region["level"])
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
endfunction"}}}

function! vorax#utils#GetCurrentRegion(descriptor, position, ...)"{{{
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
endfunction"}}}

function! vorax#utils#GetSpecRegion(descriptor, name)"{{{
  for code_region in a:descriptor
    if code_region["name"] ==? a:name && code_region["type"] ==? 'SPEC'
      return code_region
    endif
  endfor
  return {}
endfunction"}}}

function! vorax#utils#GetBodyRegion(descriptor, name)"{{{
  for code_region in a:descriptor
    if code_region["name"] ==? a:name && code_region["type"] ==? 'BODY'
      return code_region
    endif
  endfor
  return {}
endfunction"}}}

function! vorax#utils#GetDirectSubRegions(descriptor, region)"{{{
  let result = []
  for code_region in a:descriptor
    if (code_region["level"] == a:region["level"] + 1) &&
          \ (code_region["start_pos"] > a:region["start_pos"]) &&
          \ (code_region["end_pos"] < a:region["end_pos"])
      call add(result, code_region)
    endif
  endfor
  return result
endfunction"}}}

function! vorax#utils#IsEmpty(str) abort "{{{
  if vorax#utils#Strip(a:str) == ''
    return 1
  else
    return 0
  endif
endfunction "}}}

function! vorax#utils#CloseWin(name)"{{{
  let bufNo = bufnr(a:name)
  if bufNo != -1 
    let winnr = bufwinnr(bufNo)
    if winnr != -1
      exec winnr . 'wincmd w'
      try
        close!
      catch /^Vim\%((\a\+)\)\=:E444/
        echo 'Last window baby!'
      endtry
      wincmd p
    endif
  endif
endfunction"}}}

function! vorax#utils#MergeOptions(target, source) "{{{
  for item in items(a:source)
    if has_key(a:target, item[0])
      let a:target[item[0]] = item[1]
    endif
  endfor
endfunction "}}}

function! vorax#utils#GetState(...) "{{{
  let opts = {}
  for item in a:000
    let opts[item] = eval("&" . item)
  endfor
  return opts
endfunction "}}}

function! vorax#utils#SetState(options) "{{{
  for item in items(a:options)
    exe "let &" .item[0] . "=" . item[1]
  endfor
endfunction "}}}

function! vorax#utils#LiteralRegexp(text) "{{{
  return escape(a:text, '^$.*\[]~')
endfunction "}}}

function! vorax#utils#PromptPassword(msg) "{{{
  let pwd = inputsecret(a:msg)
  let r_pwd = inputsecret('Retype ' . a:msg)
  if pwd != r_pwd
    call vorax#utils#SpitWarn("Passwords don't match!")
    return ''
  endif
  return pwd
endfunction "}}}

function! vorax#utils#StringFiller(char, width) "{{{
  let spacer = ""
  let width = a:width
  while width > 0
    let spacer = spacer . a:char
    let width = width - 1
  endwhile
  return spacer
endfunction "}}}

function! vorax#utils#FocusCandidateWindow() "{{{
  let winlist = []
  " iterate through all windows and get info from them
  windo let winlist += [[winnr(), &buftype]]
  for w in winlist
    if w[1] == ""
      " great! we just found a suitable window... focus it please
      exe w[0] . 'wincmd w'
      return
    endif
  endfor
endfunction "}}}

function! s:ParseOffset(line, column) abort"{{{
  if g:vorax_parse_min_lines > 0
    let offset = a:line - g:vorax_parse_min_lines
    if offset > 0
      return offset
    endif
  endif
  return 0
endfunction"}}}

function! vorax#utils#IsVoraxManagedFile(file) "{{{
  let ext = fnamemodify(a:file, ':e')
  if ext ==? 'sql'
    return 1
  else
    for managed_ext in values(g:vorax_plsql_associations)
      if ext ==? managed_ext
        return 1
      endif
    endfor
    return 0
  endif
endfunction "}}}

