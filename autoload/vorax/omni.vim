" File:        autoload/vorax/omni.vim
" Author:      Alexandru Tică
" Description: Provides omni completion.
" License:     see LICENSE.txt

let s:cache_items = {}

function! vorax#omni#Complete(findstart, base) abort"{{{
	call VORAXDebug("vorax#omni#Complete START => a:findstart=" . string(a:findstart) . " a:base=" . string(a:base))
  if a:findstart
    let s:context = s:CompletionContext()
		call VORAXDebug("vorax#omni#Complete END => context = " . string(s:context))
    return s:context['start_from']
  else
    let items = []
    if s:context['completion_type'] == 'argument'
			call VORAXDebug("vorax#omni#Complete START ArgumentItems")
      let items = s:ArgumentItems(a:base)
			call VORAXDebug("vorax#omni#Complete END ArgumentItems")
    elseif s:context['completion_type'] == 'identifier'
			call VORAXDebug("vorax#omni#Complete START WordItems")
      let items = s:WordItems(a:base)
			call VORAXDebug("vorax#omni#Complete END WordItems")
    elseif s:context['completion_type'] == 'dot'
			call VORAXDebug("vorax#omni#Complete START DotItems")
      let items = s:DotItems(a:base)
			call VORAXDebug("vorax#omni#Complete END DotItems")
    endif
    if g:vorax_omni_sort_items
      call sort(items, "s:CompareOmniItems")
    endif
		call VORAXDebug("vorax#omni#Complete END")
    if len(items) > 0
      return items
    else
      return -2
    endif
  endif
endfunction"}}}

function! vorax#omni#SupertabPreventCompletion(text) abort"{{{
  if s:ShouldCompleteArgument(s:NonEmptyAbove())
    return 0
  endif
  if a:text =~ '\m^\s*$'
    return 1
  else
    return 0
  endif
endfunction"}}}

function! vorax#omni#ResetCache() abort"{{{
  let s:cache_items = {}
endfunction"}}}

function! s:WordItems(prefix) abort"{{{
  call VORAXDebug("omni s:WordItems a:prefix=" . string(a:prefix))
  let output = vorax#sqlplus#RunVoraxScript('omni_word.sql',
        \ toupper(a:prefix),
        \ g:vorax_omni_max_items + 1)
  call VORAXDebug('omni s:WordItems: ' . output)
  let data  = vorax#ruby#ParseResultset(output)
  let local_items = s:LocalItems()
  if exists('data["resultset"][0]')
		if exists('local_items["resultset"][0]')
			call extend(data['resultset'][0], local_items['resultset'][0])
		endif
  else
		let data['resultset'] = local_items['resultset']
	endif
  let result = s:ResultsetToOmni(data, 0, s:context['text_before'], '')
	call filter(result, 'v:val.word =~ ''^' . a:prefix . '''')
  return result
endfunction"}}}

function! s:LocalItems() abort"{{{
  " where are we?
	let result = {'resultset' : [[]]}
	let crr_pos = s:context['absolute_pos']
	" tell me more about the code structure
	let descriptor = sort(vorax#ruby#PlsqlRegions(vorax#utils#BufferContent()), 'vorax#utils#CompareRegionsByLevelDesc')
  let crr_region = vorax#utils#GetCurrentRegion(descriptor, crr_pos, '\m\(FUNCTION\)\|\(PROCEDURE\)')
  let top_region = vorax#utils#GetTopRegion(descriptor, crr_pos)
	let buffer_content = vorax#utils#BufferContent()

	" if we're on a PLSQL package or type
	if top_region != {} && 
				\ (top_region["type"] == 'BODY' || top_region["type"] == 'SPEC')
		" it makes sense to extract info from current spec
		let spec = vorax#utils#GetSpecRegion(descriptor, top_region["name"])
		if spec != {}
			" Parse the spec from the current buffer
			let source = strpart(buffer_content, spec["start_pos"], spec["end_pos"] - spec["start_pos"])
			let items = s:DeclareItems(source)
			if exists("items['resultset']")
				let result['resultset'] = items['resultset']
			endif
		else
			" Parse the spec from dictionary
			let name_metadata = vorax#sqlplus#NameResolve(top_region["name"])
			if g:vorax_omni_parse_package
				let data = s:DeclareItems(vorax#sqlplus#GetSource(name_metadata['schema'], name_metadata['object']))
			else
				" get all functions/procedures from the package or type
				let data = s:PlsqlModules(name_metadata['id'])
			endif
			if exists("data['resultset']")
				let result['resultset'] = data['resultset']
			endif
		endif
		if top_region["type"] == 'BODY'
			" if we're on a body, it's a good idea to get the private global
			" declaration
			let subregions = vorax#utils#GetDirectSubRegions(descriptor, top_region)
			let body_content = strpart(buffer_content, top_region["start_pos"])
			let global_private = vorax#utils#RemoveDirectSubRegions(body_content, descriptor, top_region)
			let global_private = vorax#ruby#RemoveAllComments(global_private)
			let global_private = substitute(global_private, '\m\<begin\>.*$', '', 'g')
			let items = s:DeclareItems(global_private)
			if exists("items['resultset'][0]")
				call extend(result['resultset'][0], items['resultset'][0])
			endif
		endif
	endif

	" if on a FOR...LOOP then add the local counter/cursor variable
  let crr_block = vorax#utils#GetCurrentRegion(descriptor, crr_pos)
	if crr_block != {} && crr_block['type'] == 'FOR_BLOCK'
		" add local FOR variables from the outter loops
		while 1
      let upper = vorax#utils#GetUpperRegion(descriptor, crr_block)
			if upper == {}
				break
			else
				let context = crr_block['context']
				if context != {} && context['for_var'] != ''
					call add(result['resultset'][0], [context['for_var'], context['for_var'], 'local', ''])
				endif
				let crr_block = upper
			endif
		endwhile
	endif

	" local items related to the declare part of the current region
	call s:ExtractDeclareItems(buffer_content, descriptor, crr_region, result)
	return result
endfunction"}}}

function! s:ExtractDeclareItems(source, descriptor, crr_region, data)"{{{
	if a:crr_region != {}
		call add(a:data['resultset'][0], [a:crr_region['name'], a:crr_region['name'], a:crr_region['type'], ''])
		let source = strpart(a:source, a:crr_region["start_pos"], a:crr_region["body_start_pos"] - a:crr_region["start_pos"])
		let subregions = vorax#utils#GetDirectSubRegions(a:descriptor, a:crr_region)
		for subregion in subregions
			" add declare modules (local procedures and functions)
			call add(a:data['resultset'][0], [subregion['name'], subregion['name'], subregion['type'], ''])
		endfor
		let source = vorax#utils#RemoveDirectSubRegions(source, a:descriptor, a:crr_region)
		let items = s:DeclareItems(source)
		if exists("items['resultset'][0]")
			call extend(a:data['resultset'][0], items['resultset'][0])
		endif
		let crr_region = vorax#utils#GetUpperRegion(a:descriptor, a:crr_region, '\m\(FUNCTION\)\|\(PROCEDURE\)')
		call s:ExtractDeclareItems(a:source, a:descriptor, crr_region, a:data)
	end
endfunction"}}}

function! s:DotItems(prefix) abort"{{{
  call VORAXDebug("omni s:DotItems a:prefix=" . string(a:prefix))
  let start = match(s:context['text_before'], '\m[a-zA-Z0-9$#_.]*$') " last blank
  let end = strridx(s:context['text_before'], '.')       " last dot
  let oracle_name = strpart(s:context['text_before'], start, end - start)
  call VORAXDebug("omni s:DotItems oracle_name=" . string(oracle_name))
  if oracle_name != ''
    " before anything else, check if it's an alias
    if oracle_name !~ '\m\.' 
			let result = s:AliasItems(oracle_name, a:prefix)
			if len(result) > 0
				" it's an alias: just return its columns
				return result
			endif
			" it could be a local FOR..LOOP variable
    	let result = s:DotItemsForLocalLoop(oracle_name, a:prefix)
      if len(result) > 0
        " it's an alias: just return its columns
        return result
      endif
    endif
    " if here, it means it's not an alias. Hope it's a qualified
    " oracle object
  	let data = s:QualifiedNameItems(oracle_name, a:prefix)
  endif

  let result = []
  if exists('data')
    call VORAXDebug("s:DotItems data=" . string(data))
    let result = s:ResultsetToOmni(data, 0, s:context['text_before'], '')
    call filter(result, 'v:val.word =~ ''^' . a:prefix . '''')
  endif

  return result
endfunction"}}}

function! s:QualifiedNameItems(oracle_name, prefix)"{{{
	let name_metadata = vorax#sqlplus#NameResolve(a:oracle_name)
	if s:IsCached(name_metadata)
		let data = s:Cache(name_metadata)
	else
		if name_metadata['type'] == 'SCHEMA'
			" get all schema objects matching the prefix
			let data = s:SchemaObjects(name_metadata['schema'], a:prefix)
		elseif name_metadata['type'] == 'PACKAGE'
			if g:vorax_omni_parse_package
				let data = s:DeclareItems(vorax#sqlplus#GetSource(name_metadata['schema'], name_metadata['object'], name_metadata['type']))
			else
				" get all functions/procedures from the package or type
				let data = s:PlsqlModules(name_metadata['id'])
			endif
		elseif name_metadata['type'] == 'TYPE'
			" get all functions/procedures from the package or type
			let data = s:PlsqlModules(name_metadata['id'])
		elseif name_metadata['type'] == 'TABLE' ||
					\ name_metadata['type'] == 'VIEW'
			" get all columns
			let data = s:Columns(name_metadata['schema'],
						\ name_metadata['object'])
		elseif name_metadata['type'] == 'SEQUENCE'
			let data = {'resultset' : [[ 
						\ ['nextval', 'nextval', '', ''], 
						\ ['currval', 'currval', '', ''] 
						\ ]]}
		endif
		if exists('data')
			call s:Cache(name_metadata, data)
		endif
	endif
	return data
endfunction"}}}

function! s:DotItemsForLocalLoop(variable, prefix)"{{{
	let crr_pos = s:context['absolute_pos']
	" tell me more about the code structure
	let descriptor = sort(vorax#ruby#PlsqlRegions(vorax#utils#BufferContent()), 'vorax#utils#CompareRegionsByLevelDesc')
	let crr_block = vorax#utils#GetCurrentRegion(descriptor, crr_pos)
	if crr_block != {} && crr_block['type'] == 'FOR_BLOCK'
		" add local FOR variables from the outter loops
		while 1
			let upper = vorax#utils#GetUpperRegion(descriptor, crr_block)
			if upper == {}
				break
			else
				let context = crr_block['context']
				if context != {} && context['for_var'] == a:variable
					if context['expr'] != ''
						let expr = 'select * from ' . context['expr'] . ' ' . a:variable
						return s:AliasItems(a:variable, a:prefix, expr)
					elseif context['cursor_var'] != ''
						" a cursor variable
					endif
				endif
				let crr_block = upper
			endif
		endwhile
	endif
	return []
endfunction"}}}

function! s:ArgumentItems(prefix) abort"{{{
  let result = []
  let stmt = vorax#utils#DescribeCurrentStatement(0, 0)
  call VORAXDebug("omni s:ArgumentItems(): stmt = " . string(stmt))
  " look backward in the current statement
  let module = vorax#ruby#ArgumentBelongsTo(stmt['text'], stmt['relative'])
  call VORAXDebug("omni s:ArgumentItems(): module = " . string(module))
  if module != ""
    " try to resolve this module
    let module_metadata = vorax#sqlplus#NameResolve(module)
    if module_metadata['type'] == 'FUNCTION' ||
          \ module_metadata['type'] == 'PROCEDURE' ||
          \ module_metadata['type'] == 'PACKAGE' ||
          \ module_metadata['type'] == 'TYPE'
      if s:IsCached(module_metadata)
        let data = s:Cache(module_metadata)
      else
        " successfully resolved, go on
        let output = vorax#sqlplus#RunVoraxScript('omni_arguments.sql',
              \ module_metadata['id'],
              \ module_metadata['extra'])
        let data  = vorax#ruby#ParseResultset(output)
        call s:Cache(module_metadata, data)
      endif
      call VORAXDebug("s:ArgumentItems data=" . string(data))
      let result = s:ResultsetToOmni(data, 1, module, ' ')
    endif
  endif
  return result
endfunction"}}}

function! s:AliasItems(alias, prefix, ...) abort"{{{
  call VORAXDebug("omni s:AliasItems alias=" . string(a:alias). " prefix=" . string(a:prefix))
  let expanded_columns = []
  if exists("a:1")
  	let stmt = {'text' : a:1, 'relative' : 1}
  else
		let stmt = vorax#utils#DescribeCurrentStatement(0, 0)
	endif
  let columns = vorax#ruby#AliasColumns(stmt.text, a:alias, stmt.relative - 1)
  call VORAXDebug("omni s:AliasItems alias columns=" . string(columns))
  for column in columns
    if column =~ '\m\*$'
      " expand baby
      let oracle_name = substitute(column, '\m\.\*$', '', 'g')
      let metadata = vorax#sqlplus#NameResolve(oracle_name)
      if metadata['type'] == 'TABLE' || metadata['type'] == 'VIEW'
        if s:IsCached(metadata)
          let data = s:Cache(metadata)
        else
          let data = s:Columns(metadata['schema'], metadata['object'])
          call s:Cache(metadata, data)
        endif
				call extend(expanded_columns, s:ResultsetToOmni(data, 0, s:context['text_before'], ''))
      endif
    else
      let rec = { 'word' : column,
                \ 'abbr' : column,
                \ 'kind' : 'column',
                \ 'menu' : '',
                \ 'icase' : 1,
                \ 'dup'  : 0 }
      call s:ConvertToOmniCase(rec, s:context['text_before'])    
      call add(expanded_columns, rec)
    endif
  endfor
  call VORAXDebug("omni s:AliasItems expanded_columns=" . string(expanded_columns))
  call filter(expanded_columns, 'v:val.word =~ ''^' . a:prefix . '''')
  return expanded_columns
endfunction"}}}

function! s:SchemaObjects(schema, prefix) abort"{{{
  let output = vorax#sqlplus#RunVoraxScript('omni_schema.sql',
        \ a:schema,
        \ toupper(a:prefix),
        \ g:vorax_omni_max_items + 1)
  return vorax#ruby#ParseResultset(output)
endfunction"}}}

function! s:DeclareItems(source) abort"{{{
  call VORAXDebug('omni s:DeclareItems: source=' . string(a:source))
  let content = vorax#ruby#RemoveAllComments(a:source)
  call VORAXDebug('omni s:DeclareItems: describe package...')
  let data = vorax#ruby#DescribeDeclare(content)
  call VORAXDebug('omni s:DeclareItems: data=' . string(data))
  let result = {'resultset' : [[]]} " to match the format of a resultset from the database
  for component in ['constants', 'variables', 'types', 'cursors', 'functions', 'procedures']
    for item in data[component]
      let rec = [item, item, strpart(component, 0, len(component) - 1), '']
      call s:ConvertToOmniCase(rec, s:context['text_before'])    
      call add(result.resultset[0], rec)
    endfor
  endfor
  return result
endfunction"}}}

function! s:PlsqlModules(object_id) abort"{{{
  let output = vorax#sqlplus#RunVoraxScript('omni_modules.sql', a:object_id)
  return vorax#ruby#ParseResultset(output)
endfunction"}}}

function! s:Columns(schema, object) abort"{{{
  let output = vorax#sqlplus#RunVoraxScript('omni_columns.sql',
        \ a:schema,
        \ a:object)
  return vorax#ruby#ParseResultset(output)
endfunction"}}}

function! s:CompletionContext() abort"{{{
  let context = { 'start_from' : -1,
                \ 'current_line' : strpart(getline('.'), 0, col('.') - 1),
                \ 'current_col' : col('.'),
								\ 'absolute_pos' : line2byte(line('.')) + col('.') - 1,
                \ 'text_before' : s:NonEmptyAbove(),
                \ 'completion_type' : ''}

  " guess completion type on the current position
  if s:ShouldCompleteArgument(context['text_before'])
    let context['completion_type'] = 'argument'
    let context['start_from'] = col('.') - 1
  else
    let context['start_from'] = s:DotMatch(context['current_line'])
    if context['start_from'] != -1
      let context.completion_type = 'dot'
    else
      let context['start_from'] = s:IdentifierMatch(context['current_line'])
      if context['start_from'] != -1
        let context.completion_type = 'identifier'
      endif
    endif
  endif
  return context
endfunction"}}}

function! s:ResultsetToOmni(data, allow_dup, case_probe, padd_with) abort"{{{
  let result = []
  let data = a:data
  if exists('data["resultset"][0]')
    let rs = data["resultset"][0]
    if len(rs) > g:vorax_omni_max_items
      " too many items, give up
      call VORAXDebug("omni s:ResultsetToOmni => Too many items")
      call vorax#utils#SpitWarn('Too many completion items...')
      " wait, otherwise the user can't see the above message
      if g:vorax_omni_too_many_items_warn_delay > 0
        exe 'sleep ' . g:vorax_omni_too_many_items_warn_delay . 'm'
      endif
    else
      for rec in rs
        call s:ConvertToOmniCase(rec, a:case_probe)    
        " the extra ws for word is needed because sqlplus doesn't
        " preserve the trailing ws
        if rec[2] == 'constant' && g:vorax_omni_force_upcase_const
          let rec[0] = toupper(rec[0])
          let rec[1] = toupper(rec[1])
        endif
        call add(result, {
              \ 'word' : rec[0] . a:padd_with,
              \ 'abbr' : rec[1],
              \ 'kind' : rec[2],
              \ 'menu' : rec[3],
              \ 'icase': 1,
              \ 'dup'  : str2nr(a:allow_dup)})
      endfor
    endif
  endif
  return result
endfunction"}}}

function! s:ShouldCompleteArgument(text) abort"{{{
  return a:text =~ '\m[(,]\s*$'
endfunction"}}}

function! s:DotMatch(text) abort"{{{
  return match(a:text, '\m\([.]\)\@<=\w*$')
endfunction"}}}

function! s:IdentifierMatch(text) abort"{{{
  return match(a:text, '\m[A-Za-z0-9#$_]\{' . g:vorax_omni_word_prefix_size . ',\}$')
endfunction"}}}

function! s:NonEmptyAbove() abort"{{{
  let line_no = line('.')
  let col_no = col('.')
  let first = 1
  if line_no > 0
    while 1
      let text = getline(line_no)
      if line_no <= 0 || text =~ '\S'
        break
      endif
      let first = 0
      let line_no -= 1
    endwhile
    if first
      return strpart(text, 0, col_no - 1)
    else
      return text
    endif
  else
    return ''
  endif
endfunction"}}}

function! s:DetectCase(...) abort"{{{
  if exists('a:1')
    let base = a:1
  else
    let base = s:context['text_before']
  endif
  let last_letter = matchstr(substitute(base, '\V\A\$', '', 'g'), '\V\a\$')
  if last_letter ==# tolower(last_letter)
    return 'lower'
  elseif last_letter ==# toupper(last_letter)
    return 'upper'
  endif
endfunction"}}}

function! s:OmniCase(...) abort"{{{
  let omni_case = g:vorax_omni_case
  if omni_case ==? 'smart' ||
        \ omni_case ==? 'upper' ||
        \ omni_case ==? 'lower'
    let omni_case = tolower(omni_case)
  endif
  if omni_case == 'smart'
    if exists('a:1')
      let base = a:1
      let omni_case = s:DetectCase(base)
    else
      let omni_case = s:DetectCase()
    endif
  endif
  return omni_case
endfunction"}}}

function! s:ConvertToOmniCase(array, ...)"{{{
  if exists('a:1')
    let case = s:OmniCase(a:1)
  else
    let case = s:OmniCase()
  endif
  if case == 'lower'
    return map(a:array, 'tolower(v:val)')
  elseif case == 'upper'
    return map(a:array, 'toupper(v:val)')
  endif
endfunction"}}}

function! s:CompareOmniItems(i1, i2)"{{{
  let i1 = toupper(a:i1.word)
  let i2 = toupper(a:i2.word)
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction"}}}

function! s:IsCached(metadata) abort"{{{
  let key = a:metadata['id'] . ':' . a:metadata['extra']
  return has_key(s:cache_items, key)
endfunction"}}}

function! s:Cache(metadata, ...) abort"{{{
  if a:metadata.id != ''
    let key = a:metadata.id . ':' . a:metadata.extra
    if exists('a:1')
      let data = a:1
      for cache_schema in g:vorax_omni_cache
        if cache_schema ==? a:metadata['schema']
          if len(data) > 0
            let s:cache_items[key] = data
          endif
          break
        endif
      endfor
    else
      if s:IsCached(a:metadata)
        return s:cache_items[key]
      endif
    endif
  endif
endfunction"}}}

