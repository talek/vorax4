" File:        autoload/vorax/omni.vim
" Author:      Alexandru Tică
" Description: Provides omni completion.
" License:     see LICENSE.txt

let s:cache_items = {}
let s:plsql_struct_key = 'plsql_struct'

function! vorax#omni#Complete(findstart, base) abort "{{{
  call VORAXDebug("vorax#omni#Complete START => a:findstart=" . string(a:findstart) . " a:base=" . string(a:base))
  if a:findstart
    let s:context = s:CompletionContext()
    call VORAXDebug("vorax#omni#Complete END => context = " . string(s:context))
    return s:context['start_from']
  else
    let old_lz = &lz
    set lz
    if s:context.completion_type ==? 'identifier' || s:context.completion_type ==? 'dot'
      " tell me more about the code structure
      let text_code = vorax#utils#BufferContent(1, line('.')) . a:base
      if b:sql_type_override ==? 'plsqlvorax'
        " a plsql buffer
        call vorax#ruby#ComputePlsqlStructure(s:plsql_struct_key, text_code)
        let s:context.local_items = vorax#ruby#LocalItems(s:plsql_struct_key, 
              \ s:context.absolute_pos - 1, '')
      elseif b:sql_type_override ==? 'sqlvorax'
        " a sql buffer
        let stmt = vorax#ruby#CurrentStatement(text_code, 
              \ s:context.absolute_pos - 1, 
              \ 1, 0)
        call vorax#ruby#ComputePlsqlStructure(s:plsql_struct_key, stmt.text)
        let s:context.local_items = vorax#ruby#LocalItems(s:plsql_struct_key, 
              \ strlen(stmt.text) - 1, '')
      endif
    endif
    let items = []
    let s:context['prefix'] = a:base
    try
      if s:context['completion_type'] == 'argument'
        let items = s:ArgumentItems(a:base)
      elseif s:context['completion_type'] == 'identifier'
        let items = s:WordItems(a:base)
      elseif s:context['completion_type'] == 'dot'
        let items = s:DotItems(a:base)
      elseif s:context['completion_type'] == 'dblink'
        let items = s:DbLinksItems(a:base)
      endif
    catch /^VRX-03/
      call vorax#utils#WarnBusy()
    endtry
    if g:vorax_omni_sort_items
      call sort(items, "s:CompareOmniItems")
    endif
    call VORAXDebug("vorax#omni#Complete END")
    let &lz=old_lz
    if len(items) > 0
      return items
    else
      return -2
    endif
  endif
endfunction "}}}

function! vorax#omni#SupertabPreventCompletion(text) abort "{{{
  if s:ShouldCompleteArgument(s:NonEmptyAbove())
    return 0
  endif
  if a:text =~ '\m^\s*$'
    return 1
  else
    return 0
  endif
endfunction "}}}

function! vorax#omni#ResetCache() abort "{{{
  let s:cache_items = {}
endfunction "}}}

function! s:ArgumentItems(prefix) abort "{{{
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
      let module_metadata.cache_key = module_metadata.id . ':args'
      if s:IsCached(module_metadata)
        let data = s:Cache(module_metadata)
      else
        " successfully resolved, go on
        if module_metadata['type'] == 'FUNCTION' ||
              \ module_metadata['type'] == 'PROCEDURE'
          let package = ''
          let obj = module_metadata['object']
        else
          let package = module_metadata['object']
          let obj = module_metadata['extra']
        end
        let output = vorax#sqlplus#RunVoraxScript('omni_arguments.sql',
              \ module_metadata['schema'],
              \ package,
              \ obj)
        let data  = vorax#ruby#ParseResultset(output)
        call s:Cache(module_metadata, data)
      endif
      call VORAXDebug("s:ArgumentItems data=" . string(data))
      let result = s:ResultsetToOmni(data, 1, module, ' ')
    endif
  endif
  return result
endfunction "}}}

function! s:DbLinksItems(prefix) abort "{{{
  call VORAXDebug("omni s:DbLinksItems a:prefix=" . string(a:prefix))
  let output = vorax#sqlplus#RunVoraxScript('omni_dblinks.sql',
        \ toupper(a:prefix))
  call VORAXDebug('omni s:DbLinksItems: ' . output)
  let data  = vorax#ruby#ParseResultset(output)
  let result = s:ResultsetToOmni(data, 0, s:context['text_before'], '')
  return result
endfunction "}}}

function! s:WordItems(prefix) abort "{{{
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
  " add syntax items
  if exists("*syntaxcomplete#OmniSyntaxList")
    for item in syntaxcomplete#OmniSyntaxList()
      call add(result, {'word' : item, 'kind' : 'kyw' })
    endfor
  endif
  call filter(result, 'v:val.word =~ ''^' . vorax#utils#LiteralRegexp(a:prefix) . '''')
  " add output window items
  for item in s:OutputWindowWords(a:prefix)
    call add(result, {'word' : item, 'kind' : 'output'})
  endfor
  return result
endfunction "}}}

function! s:AddOutputWord(list, item, prefix) "{{{
  call add(a:list, a:item)
  let parts = split(a:item, '\m\W')
  if len(parts) > 1
    for part in parts
      if part =~ '\m^' . vorax#utils#LiteralRegexp(a:prefix)
        call add(a:list, part)
      endif
    endfor
  endif
endfunction "}}}

function! s:OutputWindowWords(prefix) "{{{
  let omni_words = []
  let output_bufname = vorax#output#GetBufferName()
  let visible_bounds = getbufvar(output_bufname, 'vorax_visible_bounds')
  " should be a list and have 2 elements
  if type(visible_bounds) == 3 && len(visible_bounds) == 2

    " compute the offset in case the output window was resized. We need
    " to do that because the visible bounds are updated on output window
    " LostFocus. However, if the output window was resized from another
    " window these visible bounds are not updated. So, Vorax will also
    " check the output window hight and if there are differences computes
    " an offset so that to accomodate with the new window size.
    "
    " Note: we could easily move to the output window and get the visible
    " bounds, but we don't want to move to another window while the 
    " completion is done.
    let output_window_nr = bufwinnr(output_bufname)
    if output_window_nr >= 0
      let offset = winheight(output_window_nr) - 
            \ (visible_bounds[1] - visible_bounds[0]) - 1
    else
      let offset = 0
    endif

    let up = visible_bounds[0] - offset
    if up < 0
      let up = 0
    endif

    let visible_output = getbufline(output_bufname, 
          \ up, 
          \ visible_bounds[1] + offset)
    for line in visible_output
      call substitute(line, 
            \ '\<' . vorax#utils#LiteralRegexp(a:prefix) . '[^ ]*\>', 
            \ '\=s:AddOutputWord(omni_words, submatch(0), a:prefix)' , 
            \ 'g')
    endfor
  endif
  return omni_words
endfunction "}}}

function! s:ShortLocalName(name)"{{{
  let short_name = toupper(substitute(a:name, '\m"', '', 'g'))
  let composite_name = toupper(
        \ substitute(
        \   vorax#ruby#CompositeName(s:plsql_struct_key, s:context.absolute_pos),
        \   '"', 
        \   '', 
        \   'g')
        \ )
  if composite_name != ''
    " only if we are on a composite module
    if strpart(short_name, 0, len(composite_name)) ==? composite_name
      let short_name = strpart(short_name, len(composite_name) + 1, len(short_name))
      if short_name != ''
        return short_name
      else
        return a:name
      endif
    endif
    let short_name_parts = split(short_name, '\m\.')
    let composite_name_parts = split(composite_name, '\m\.')
    if len(composite_name_parts) == 2
      let composite_schema = composite_name_parts[0]
      let composite_object = composite_name_parts[1]
    elseif len(composite_name_parts) == 1
      let composite_schema = vorax#sqlplus#Properties()['user']
      let composite_object = composite_name_parts[0]
    endif
    if exists('composite_schema')
      if len(short_name_parts) >= 2
        " is the leading part pointing to the composite name?
        if strpart(short_name, 0, len(composite_object)) ==? composite_object
          let short_name = strpart(short_name, len(composite_object) + 1, len(short_name))
        elseif composite_schema != "" && strpart(short_name, 0, len(composite_schema)) ==? composite_schema
          let short_name = strpart(short_name, len(composite_schema) + 1, len(short_name))
          if strpart(short_name, 0, len(composite_object)) ==? composite_object
            let short_name = strpart(short_name, len(composite_object) + 1, len(short_name))
          endif
        endif
      endif
    endif
    return short_name
  endif
  return a:name
endfunction"}}}

function! s:GetTextBeforeLastDot() "{{{
  let start = match(s:context['text_before'], '\m[a-zA-Z0-9$#_.]*$') " last blank
  let end = strridx(s:context['text_before'], '.')       " last dot
  return strpart(s:context['text_before'], start, end - start)
endfunction "}}}

function! s:FindLocalItem(item_name) "{{{
  for item in s:context.local_items
    if (item["item_type"] == 'ForVariable' && item["variable"] ==? a:item_name) ||
          \ (has_key(item, 'name') && item['name'] ==? a:item_name)
      return item
    endif
  endfor
  return {}
endfunction "}}}

function! s:DotItems(prefix) "{{{
  let omni_items = []
  let dot_string = s:GetTextBeforeLastDot()
  let items = copy(s:FollowDotChain(split(dot_string, '\m\.'), {}, [], 1))
  call filter(items, 'toupper(v:val["name"]) =~ ''^' . vorax#utils#LiteralRegexp(toupper(a:prefix)) . '''')
  for item in items
    let rec = s:Item2Omni(item)
    call add(omni_items, rec)
  endfor
  return s:ResultsetToOmni({'resultset' : [omni_items]}, 0, dot_string, '')
endfunction "}}}

function! s:Item2Omni(item) "{{{
  if exists('a:item["item_type"]')
    let menu = ''
    if a:item["item_type"] == 'VariableItem'
      let type = a:item["vartype"]
    elseif a:item['item_type'] == 'CursorItem'
      let type = 'cursor'
    elseif a:item['item_type'] == 'TypeItem'
      let type = 'type'
      let menu = a:item['is_a']
    elseif a:item['item_type'] == 'SubtypeItem'
      let type = 'subtype'
      let menu = a:item['is_a']
    elseif a:item['item_type'] == 'ConstantItem'
      let type = 'constant'
      let menu = a:item["vartype"]
    elseif exists("a:item['type']")
      let type = a:item["type"]
    else
      let type = ''
    endif
    if a:item["item_type"] == 'FunctionItem' ||
          \ a:item["item_type"] == 'ProcedureItem'
      let abbr = a:item['name'] . '()'
    else
      let abbr = a:item['name']
    end
    let rec = [a:item['name'],
            \  abbr,
            \  type,
            \  menu]
    return rec
  endif
  return ''
endfunction "}}}

function! s:DotHeadDescriptor(dot_parts) "{{{
  let dot_parts = a:dot_parts
  let stmt = vorax#utils#DescribeCurrentStatement(0, 0)
  if vorax#ruby#IsAliasVisible(stmt.text, dot_parts[0], stmt.relative - 1)
    " it's an alias
    let crr_item = {'item_type' : 'AliasItem',
          \ 'name' : dot_parts[0],
          \ 'statement' : stmt.text,
          \ 'relpos' : stmt.relative}
    call remove(dot_parts, 0)
  else
    let items = vorax#ruby#LocalItems(s:plsql_struct_key, s:context.absolute_pos - 1, '')

    let short_name = s:ShortLocalName(join(dot_parts, '.'))
    
    " is it a local item?
    let crr_item = s:FindLocalItem(dot_parts[0])
    if exists('crr_item["item_type"]')
      call remove(dot_parts, 0)
    else
      " it's not a local item. describe it on the database level
      let name_metadata = vorax#sqlplus#NameResolve(join(dot_parts[0:2], '.'))
      if name_metadata['schema'] != ''
        " successfully located in the dictionary
        let crr_item = s:OracleObjectItemType(name_metadata)
        if dot_parts[0] ==? name_metadata['schema']
          call remove(dot_parts, 0)
        endif
        if len(dot_parts) > 0 && dot_parts[0] ==? name_metadata['object']
          call remove(dot_parts, 0)
        endif
      endif
    endif
  endif
  return {'dot_chain' : dot_parts, 'ref' : crr_item}
endfunction "}}}

function! s:FollowDotChain(dot_parts, ref, items_acc, first) "{{{
  call VORAXDebug('omni s:FollowDotChain => a:dot_parts=' . string(a:dot_parts) .
        \ ' a:ref=' . string(a:ref) . 
        \ ' a:items_acc=' . string(a:items_acc) .
        \ ' a:first= ' . string(a:first))
  let items_acc = a:items_acc
  let dot_parts = a:dot_parts
  let ref = a:ref
  if a:first
    " we're on the first element of the dot chain
    let head_descriptor = s:DotHeadDescriptor(dot_parts)
    let ref = head_descriptor['ref']
    let dot_parts = head_descriptor['dot_chain']
    " if we know what the head is, go on and follow the chain
    if exists('ref["item_type"]')
      return s:FollowDotChain(a:dot_parts, ref, items_acc, 0)
    endif
  else
    " we're on the tail of the dot chain
    if exists('a:ref["item_type"]')
      if a:ref["item_type"] ==? 'VariableItem' || a:ref["item_type"] ==? 'ConstantItem'
        let items_acc = s:VariableTypeItems(a:ref)
      elseif a:ref["item_type"] ==? 'AliasItem'
        let items_acc = s:AliasItems(a:ref["name"], '', a:ref['statement'], a:ref['relpos'])
      elseif a:ref["item_type"] ==? 'TypeItem'
        let items_acc = s:TypeAttributes(a:ref)
      elseif a:ref["item_type"] ==? 'SubtypeItem'
        let items_acc = s:SubtypeAttributes(a:ref)
      elseif a:ref["item_type"] ==? 'OracleTypeRef'
        let items_acc = s:OracleTypeRefItems(a:ref)
      elseif a:ref["item_type"] ==? 'ForVariable'
        let items_acc = s:ForVariableItems(a:ref)
      elseif a:ref["item_type"] ==? 'CursorItem'
        let items_acc = s:CursorColumns(a:ref)
      elseif a:ref["item_type"] ==? 'ArgumentItem'
        let var_item = {'name' : a:ref['name'], 'vartype' : a:ref['data_type'], 'item_type' : 'VariableItem'}
        let items_acc = s:VariableTypeItems(var_item)
      elseif s:IsSchemaItem(a:ref)
        let items_acc = s:SchemaObjects(a:ref['metadata']['schema'], s:context['prefix'])
      elseif a:ref['item_type'] ==? 'OracleObject' && s:HasColumns(a:ref['metadata'])
        let items_acc = s:Columns(a:ref)
      elseif s:IsPackage(a:ref)
        let items_acc = s:PackageItems(a:ref)
      elseif s:IsType(a:ref)
        let items_acc = s:OracleTypeAttributes(a:ref)
      else
        " broken chain
        return []
      endif
      " compute the next ref
      if len(a:dot_parts) > 0
        for item in items_acc
          if exists("item['item_type']") && toupper(item['name']) ==? toupper(a:dot_parts[0])
            call remove(a:dot_parts, 0)
            return s:FollowDotChain(a:dot_parts, item, items_acc, 0)
          endif
        endfor
      endif
    endif
  endif
  return items_acc
endfunction "}}}

function! s:OracleTypeRefItems(attr_item) "{{{
  let items = []
  let attr_type = a:attr_item["type"]
  let name_metadata = vorax#sqlplus#NameResolve(attr_type)
  let items = s:OracleTypeAttributes(s:OracleObjectItemType(name_metadata))
  return items
endfunction "}}}

function! s:VariableTypeItems(var_item) "{{{
  let items = []
  if exists('a:var_item["global_in"]')
    let global_in = a:var_item["global_in"]
  else
    let global_in = ''
  endif
  let vartype = s:ResolveVariableType(a:var_item["vartype"],
        \ global_in)
  if exists('vartype["item_type"]')
    if vartype['item_type'] ==? 'OracleObject' 
      if vartype['metadata']['type'] ==? 'TYPE'
        let items = s:TypeAttributes(vartype)
      elseif s:HasColumns(vartype['metadata'])
        let items = s:Columns(vartype)
      endif
    elseif vartype['item_type'] ==? 'CursorItem'
      let items = s:CursorColumns(vartype)
    elseif vartype['item_type'] ==? 'OracleTypeRef'
      let items = s:OracleTypeRefItems(vartype)
    endif
  endif
  return items
endfunction "}}}

function! s:ForVariableItems(for_item) "{{{
  let items = []
  if a:for_item['domain_type'] ==? 'cursor_var'
    let var_type = s:ResolveVariableType(a:for_item['domain'])
    let a:for_item["domain_type"] = 'expr'
    let a:for_item["domain"] = '(' . var_type['query'] . ')'
  endif
  " look at the query behind
  let expr = 'select * from ' . a:for_item['domain'] . ' ' . a:for_item['variable']
  let items = s:AliasItems(a:for_item['variable'], '', expr)
  return items
endfunction "}}}

function! s:CursorColumns(cursor_item) "{{{
  let expr = 'select * from (' . 
        \ a:cursor_item['query'] . ')' . 
        \ ' vorax$$alias'
  let items = s:AliasItems('vorax$$alias', '', expr)
  return items
endfunction "}}}

function! s:OracleTypeAttributes(item) "{{{
  let items = []
  if s:IsCached(a:item['metadata'])
    let items = s:Cache(a:item['metadata'])
  else
    let vartype = a:item
    if exists('vartype["item_type"]') && vartype["item_type"] ==? "OracleObject"
      let data = s:TypeItems(vartype['metadata']['schema'], vartype['metadata']['object'])
      if exists("data['resultset'][0]")
        for rec in data['resultset'][0]
          if vorax#utils#IsEmpty(rec[2])
            call add(items, {'item_type': 'FunctionItem', 
                  \ 'type': '', 
                  \ 'name': rec[0]})
          else
            call add(items, {'item_type': 'OracleTypeRef', 
                  \ 'type': rec[2], 
                  \ 'name': rec[0]})
          endif
        endfor  
        call s:Cache(a:item['metadata'], items)
      endif
    endif
  endif
  return items
endfunction "}}}

function! s:TypeAttributes(item) "{{{
  let items = []
  let vartype = a:item
  if exists('vartype["item_type"]')
    if vartype["item_type"] ==? "TypeItem" && vartype["is_a"] ==? "record"
      let type_attrs = vorax#ruby#DescribeRecordType(vartype['text'])
      for attr in type_attrs
        call add(items, { 'item_type': 'VariableItem',
              \ 'vartype' : attr['type'],
              \ 'name' : attr['name']})
      endfor
    elseif vartype["item_type"] ==? "OracleObject"
      let items = s:OracleTypeAttributes(a:item)
    endif
  endif
  return items
endfunction "}}}

function! s:SubtypeAttributes(item) "{{{
  let items = []
  if exists('a:item["item_type"]')
    let ref = s:ResolveVariableType(a:item['defined_in'] . '.' . a:item["is_a"])
    if exists("ref['item_type']")
      if ref["item_type"] ==? "TypeItem" && ref["is_a"] ==? "record"
        let type_attrs = vorax#ruby#DescribeRecordType(ref['text'])
        for attr in type_attrs
          call add(items, { 'item_type': 'VariableItem',
                \ 'vartype' : attr['type'],
                \ 'name' : attr['name']})
        endfor
      elseif ref["item_type"] ==? "SubtypeItem"
        let items = s:SubtypeAttributes(ref)
      elseif ref["item_type"] ==? "OracleObject"
        let items = s:OracleTypeAttributes(ref)
      endif
    endif
  endif
  return items
endfunction "}}}

function! s:LocalItems() abort "{{{
  " where are we?
  let result = {'resultset' : [[]]}
  let crr_pos = s:context['absolute_pos']
    
  let args = []
  for item in s:context['local_items']
    if item["item_type"] == 'ForVariable'
      let rec = [item['variable'], item['variable'], '', '']
    elseif has_key(item, 'name')
      if item["item_type"] == 'ConstantItem'
        let rec = [item['name'], item['name'], 'constant', item['vartype']]
      elseif item["item_type"] == 'VariableItem'
        let rec = [item['name'], item['name'], 'variable', item['vartype']]
      elseif item["item_type"] == 'TypeItem'
        let rec = [item['name'], item['name'], 'type', '']
      elseif item["item_type"] == 'CursorItem'
        let rec = [item['name'], item['name'], 'cursor', '']
      elseif item["item_type"] == 'ExceptionItem'
        let rec = [item['name'], item['name'], 'exception', '']
      elseif item["item_type"] == 'FunctionItem'
        let rec = [item['name'], item['name'], 'func', '']
      elseif item["item_type"] == 'ProcedureItem'
        let rec = [item['name'], item['name'], 'proc', '']
      elseif item["item_type"] == 'ArgumentItem'
        let rec = [item['name'], item['name'], item['data_type'], 'arg ' . item['direction']]
      end
    endif
    if exists('rec')
      call add(result['resultset'][0], rec)
    endif
  endfor
  return result
endfunction "}}}

function! s:ResolveVariableType(name, ...) "{{{
  if exists('a:1')
    let global_in = a:1
  else
    let global_in = ''
  endif
  let name = s:ShortLocalName(a:name)
  let is_rowtype = 0
  let is_type = 0
  if name =~? '%rowtype$'
    let is_rowtype = 1
    let name = substitute(name, '%rowtype$', '', '')
  elseif name =~? '%type$'
    let name = substitute(name, '%type$', '', '')
    let is_type = 1
  endif
  let ref = s:FindLocalItem(name)
  if ref != {}
    return ref
  else
    " is it in another package?
    " describe it baby
    let parts = split(name, '\m\.')
    if len(parts) == 1 && !vorax#utils#IsEmpty(global_in)
      let parts = [global_in, name]
      let name = global_in . '.' . name
    endif
    let name_metadata = vorax#sqlplus#NameResolve(name)
    if is_rowtype && s:HasColumns(name_metadata)
      return s:OracleObjectItemType(name_metadata)
    elseif is_type && len(parts) > 0
      " find the type of the column
      let columns = s:Columns(s:OracleObjectItemType(name_metadata))
      call filter(columns, "v:val['name'] ==? '" . parts[-1] . "'")
      if len(columns) > 0
        return columns[0]
      endif
    elseif name_metadata['type'] == 'PACKAGE'
      " get rid of the extra field
      let name_metadata['extra'] = ''
      " get the source of the package
      if s:IsCached(name_metadata)
        let data = s:Cache(name_metadata)
      else
        let pkg_source = vorax#sqlplus#GetSource(name_metadata['schema'], 
              \ name_metadata['object'], 
              \ name_metadata['type'])
        let data = vorax#ruby#DescribeDeclare(pkg_source)
        for item in data
          if exists('item["item_type"]') && item["item_type"] ==? 'SubtypeItem'
            let item["defined_in"] = name_metadata['schema'] . '.' . name_metadata['object']
          endif
        endfor
        call s:Cache(name_metadata, data)
      endif
      let type = filter(copy(data), 
            \ 'exists(''v:val["name"]'') && toupper(v:val["name"]) ==? "' . toupper(parts[-1]) . '"')
      if len(type) > 0
        return type[0]
      endif
    elseif name_metadata['type'] == 'TYPE'
      return s:OracleObjectItemType(name_metadata)
    endif
  endif
  return {}
endfunction "}}}

function! s:OracleObjectItemType(name_metadata) "{{{
  return { 'item_type' : 'OracleObject', 
        \ 'metadata' : a:name_metadata}
endfunction "}}}

function! s:IsSchemaItem(item) "{{{
  if exists("a:item['item_type']") &&
        \ a:item['item_type'] == 'OracleObject' &&
        \ vorax#utils#IsEmpty(a:item['metadata']['id'])
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:HasColumns(metadata) "{{{
  if a:metadata['type'] == 'TABLE' ||
        \  a:metadata['type'] == 'VIEW' ||
        \  a:metadata['type'] == 'CLUSTER' ||
        \  a:metadata['type'] == 'MATERIALIZED VIEW'
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:IsPackage(item) "{{{
  if exists("a:item['item_type']") &&
        \ a:item['item_type'] ==? 'OracleObject' &&
        \ a:item['metadata']['type'] ==? 'PACKAGE'
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:IsType(item) "{{{
  if exists("a:item['item_type']") &&
        \ a:item['item_type'] ==? 'OracleObject' &&
        \ a:item['metadata']['type'] ==? 'TYPE'
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:AliasItems(alias, prefix, ...) abort "{{{
  call VORAXDebug("omni s:AliasItems alias=" . string(a:alias). " prefix=" . string(a:prefix))
  let expanded_columns = []
  if exists("a:1")
    let pos = 1
    if exists("a:2")
      let pos = a:2
    endif
    let stmt = {'text' : a:1, 'relative' : pos}
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
      if s:HasColumns(metadata)
        if s:IsCached(metadata)
          let data = s:Cache(metadata)
        else
          let data = s:Columns(s:OracleObjectItemType(metadata))
          call s:Cache(metadata, data)
        endif
        call extend(expanded_columns, data)
      endif
    else
      let parts = split(column, '\m\.')
      let alias = vorax#ruby#GetAlias(stmt.text, a:alias, stmt.relative - 1)
      let rec = { 'item_type' : 'AliasRef',
            \ 'name' : parts[-1],
            \ 'alias' : alias}
      call add(expanded_columns, rec)
    endif
  endfor
  call VORAXDebug("omni s:AliasItems expanded_columns=" . string(expanded_columns))
  call filter(expanded_columns, 'toupper(v:val.name) =~ ''^' . vorax#utils#LiteralRegexp(toupper(a:prefix)) . '''')
  return expanded_columns
endfunction "}}}

function! s:SchemaObjects(schema, prefix) abort "{{{
  let items = []
  let output = vorax#sqlplus#RunVoraxScript('omni_schema.sql',
        \ a:schema,
        \ toupper(a:prefix),
        \ g:vorax_omni_max_items + 1)
  let data = vorax#ruby#ParseResultset(output)
  if exists("data['resultset'][0]")
    for rec in data['resultset'][0]
      call add(items, {'item_type': 'OracleObject', 
            \ 'type': rec[2], 
            \ 'name': rec[0]})
    endfor  
  endif
  return items
endfunction "}}}

function! s:DeclareItems(source) abort "{{{
  call VORAXDebug('omni s:DeclareItems: source=' . string(a:source))
  let content = vorax#ruby#RemoveAllComments(a:source)
  call VORAXDebug('omni s:DeclareItems: describe package...')
  let data = vorax#ruby#DescribeDeclare(content)
  call VORAXDebug('omni s:DeclareItems: data=' . string(data))
  let result = {'resultset' : [[]]} " to match the format of a resultset from the database
  for item in data
    let rec = [item['name'], item['name'], item['is_a'], '']
    call s:ConvertToOmniCase(rec, s:context['text_before'])    
    call add(result.resultset[0], rec)
  endfor
  return result
endfunction "}}}

function! s:PackageItems(item) abort "{{{
  let items = []
  let metadata = copy(a:item['metadata'])
  " get rid of the extra field
  let metadata['extra'] = ''
  if s:IsCached(metadata)
    let items = s:Cache(metadata)
  else
    if g:vorax_omni_parse_package
      let pkg_source = vorax#sqlplus#GetSource(metadata['schema'], 
            \ metadata['object'], 
            \ metadata['type'])
      let items = vorax#ruby#DescribeDeclare(pkg_source)
      for item in items
        if exists('item["item_type"]') && item["item_type"] ==? 'SubtypeItem'
          let item["defined_in"] = metadata['schema'] . '.' . metadata['object']
        endif
      endfor
      call s:Cache(metadata, items)
    else
      " look into the db dictionary
      let output = vorax#sqlplus#RunVoraxScript('omni_modules.sql', metadata["id"])
      let data  = vorax#ruby#ParseResultset(output)
      if exists("data['resultset'][0]")
        for rec in data['resultset'][0]
          call add(items, {'item_type': (rec[2] != '' ? 'FunctionItem' : 'ProcedureItem'), 
                \ 'type': rec[2], 
                \ 'name': rec[0]})
        endfor  
        call s:Cache(metadata, items)
      endif
    endif
  endif
  return items
endfunction "}}}

function! s:Columns(item) abort "{{{
  let schema = a:item['metadata']['schema']
  let object = a:item['metadata']['object']
  let items = []
  if s:IsCached(a:item['metadata'])
    let items = s:Cache(a:item['metadata'])
  else
    let output = vorax#sqlplus#RunVoraxScript('omni_columns.sql',
          \ schema,
          \ object)
    let data = vorax#ruby#ParseResultset(output)
    if exists("data['resultset'][0]")
      for rec in data['resultset'][0]
        call add(items, {'item_type': 'OracleTypeRef', 
              \ 'type': rec[2], 
              \ 'name': rec[0]})
      endfor  
      call s:Cache(a:item['metadata'], items)
    endif
  endif
  return items
endfunction "}}}

function! s:TypeItems(schema, object) abort "{{{
  let output = vorax#sqlplus#RunVoraxScript('omni_type_items.sql',
        \ a:schema,
        \ a:object)
  return vorax#ruby#ParseResultset(output)
endfunction "}}}

function! s:CompletionContext() abort "{{{
  let context = { 'start_from' : -1,
                \ 'current_line' : strpart(getline('.'), 0, col('.') - 1),
                \ 'prefix' : '',
                \ 'current_col' : col('.'),
                \ 'absolute_pos' : line2byte(line('.')) + col('.') - 1,
                \ 'text_before' : s:NonEmptyAbove(),
                \ 'local_items' : [],
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
      let context['start_from'] = s:DbLinkMatch(context['current_line'])
      if context['start_from'] != -1
        let context.completion_type = 'dblink'
      else
        let context['start_from'] = s:IdentifierMatch(context['current_line'])
        if context['start_from'] != -1
          let context.completion_type = 'identifier'
        endif
      endif
    endif
  endif
  return context
endfunction "}}}

function! s:ResultsetToOmni(data, allow_dup, case_probe, padd_with) abort "{{{
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
endfunction "}}}

function! s:ShouldCompleteArgument(text) abort "{{{
  return a:text =~ '\m[(,]\s*$'
endfunction "}}}

function! s:DotMatch(text) abort "{{{
  return match(a:text, '\m\([a-zA-Z0-9#$][.]\)\@<=[a-zA-Z0-9#$]*$')
endfunction "}}}

function! s:DbLinkMatch(text) abort "{{{
  return match(a:text, '\m\([@]\)\@<=\w*$')
endfunction "}}}

function! s:IdentifierMatch(text) abort "{{{
  return match(a:text, '\m[A-Za-z0-9#$_]\{' . g:vorax_omni_word_prefix_size . ',\}$')
endfunction "}}}

function! s:NonEmptyAbove() abort "{{{
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
endfunction "}}}

function! s:DetectCase(...) abort "{{{
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
endfunction "}}}

function! s:OmniCase(...) abort "{{{
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
endfunction "}}}

function! s:ConvertToOmniCase(array, ...) "{{{
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
endfunction "}}}

function! s:CompareOmniItems(i1, i2) "{{{
  let i1 = toupper(a:i1.word)
  let i2 = toupper(a:i2.word)
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction "}}}

function! s:CacheKey(metadata) abort "{{{
  let extra = a:metadata.extra
  if a:metadata.type == 'PACKAGE' ||
        \ a:metadata.type == 'TYPE'
    let extra = ''
  endif
  if exists("a:metadata.cache_key")
    let key = a:metadata.cache_key
  else
    let key = a:metadata.id . ':' . extra
  endif
  return key
endfunction "}}}

function! s:IsCached(metadata) abort "{{{
  return has_key(s:cache_items, s:CacheKey(a:metadata))
endfunction "}}}

function! s:Cache(metadata, ...) abort "{{{
  if a:metadata.id != ''
    let key = s:CacheKey(a:metadata)
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
        return copy(s:cache_items[key])
      endif
    endif
  endif
endfunction "}}}

