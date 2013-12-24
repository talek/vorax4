" File:        voraxlib/tree.vim
" Author:      Alexandru Tică
" Description: provides a basic treeview API.
" License:     see LICENSE.txt

let s:instances = {}
let s:tree = {
      \ 'name' : '__UNNAMED__',
      \ 'root' : '/',
      \ 'path_separator' : ' >> ',
      \ 'style' : 'vertical',
      \ 'side' : 'left',
      \ 'span' : 1,
      \ 'size' : 10,
      \ 'min_size' : 10,
      \ '_state' : []
      \ }

" Public interface
function! vorax#tree#New(options) "{{{
  let tree = copy(s:tree)
  call vorax#utils#MergeOptions(tree, a:options)
  let tree._window = vorax#window#New(
        \ {'name': tree.name,
        \  'style' : tree.style,
        \  'side' : tree.side,
        \  'size' : tree.size,
        \  'span' : tree.span,
        \  'min_size' : tree.min_size})
  let s:instances[tree.name] = tree
  return tree
endfunction "}}}

function! s:tree.Open() "{{{
  call self._window.Open()
  
  " a wrapped tree would look really weird
  setlocal nowrap

  " default keys
  exe 'noremap <silent> <buffer> o :call <SID>OpenNode("' . self.name . '")<CR>'
  exe 'noremap <silent> <buffer> <CR> :call <SID>OpenNode("' . self.name . '")<CR>'

  " let others configure the tree
  call self.ConfigureOptions()
  call self.ConfigureKeys()
  call self.ConfigureColors()

  " built it baby
  call self._buildTree(self.root)
endfunction "}}}

function! s:tree.Toggle() "{{{
  let bufNo = bufnr(self.name)
  if bufNo == -1 
    " was never opened
    call self.Open()
  else
    " toggle just the window
    call self._window.Toggle()
    if self._window.IsOpen()
      call self.ConfigureOptions()
    end
  endif
endfunction "}}}

function! s:tree.Close() "{{{
  call self._window.Close()
endfunction "}}}

function! s:tree.ResetState() "{{{
  let self._state = []
endfunction "}}}

function! s:tree.RevealNode(path) "{{{
  " split the provided path
  let parts = split(a:path, self.path_separator)
  normal! gg
  let ypos = 1
  let indent = 0
  let index = 1
  " loop through all path components.
  for part in parts
    " scan tree buffer
    let found = 0
    while ypos <= line('$')
      let line = getline(ypos)
      if index == 1 && line == part
        " that's the root node
        let found = 1
        break
      elseif index > 1 && line =~ '\m^\s\{' . indent . '\}[+ -]' . vorax#utils#LiteralRegexp(part)
        " If it's not the last part from the path and it's collapsed
        if index < len(parts) && line =~ '\m^\s\{' . indent . '\}[+]'
          " the node is collapsed therefore it have to be expanded in order to
          " find it's children
          exe 'normal! ' . ypos . 'G'
          call self._expandCurrentNode()
        endif
        let found = 1
        break
      endif
      let ypos += 1
    endwhile
    if !found 
      return
    else
      let ypos += 1
      let index += 1
      if index > 2
        let indent += 1
      endif
    endif
  endfor
  exe 'normal!' . (ypos - 1) . 'G'
endfunction!"}}}

function! s:tree.GetWindow() "{{{
  return self._window
endfunction "}}}

function! s:tree.RebuildTree(...) "{{{
  if a:0 > 0 && a:1 == 1
    call self.ResetState()
  endif
  call self._buildTree(getline(1))
endfunction "}}}

function! s:tree.SetPath(path, ...) "{{{
  if a:0 > 0 && a:1 == 1
    call self.ResetState()
  endif
  let self.root = a:path
  call self._buildTree(a:path)
endfunction "}}}

function! s:tree.GetPathUnderCursor() "{{{
  " save cursor position
  let save_pos = getpos(".")
  normal! 1|g^
  let xpos = col('.') - 1
  let ypos = line('.')
  let path = self._getPathName(xpos, ypos)
  call setpos('.', save_pos)
  return path
endfunction "}}}

" May be redefined in subclasses
function! s:tree.GetSubNodes (path) "{{{1
endfunction "}}}1

function! s:tree.ConfigureOptions() "{{{
endfunction "}}}

function! s:tree.ConfigureKeys() "{{{
endfunction "}}}

function! s:tree.ConfigureColors() "{{{
endfunction "}}}

function! s:tree.OpenNode(path)"{{{
endfunction"}}}

function! s:tree.IsLeaf(path) "{{{
  return 0
endfunction "}}}

" Private methods
function! s:tree._buildTree(initialPath) "{{{
  let path = a:initialPath
  call self._window.Focus()
  call self._window.Unlock()
  
  " clean up
  call self._window.Clear()

  call setline(1, path)
  call self._window.Lock()

  call self._treeExpand(-1, 1)
  
  " move to first entry
  norm! ggj1|g^

  call self._restoreState()
endfunction "}}}

function! s:tree._restoreState() "{{{
  call self._removeOrphans()
  let state = copy(self._state)
  call self.ResetState()
  for node in state
    call self.RevealNode(node)
    call self._expandCurrentNode()
  endfor
endfunction "}}}

function! s:tree._removeOrphans() "{{{
  let state = copy(self._state)
  " remove all invalid nodes from the state
  for idx in range(len(state))
    if len(self.GetSubNodes(state[idx])) == 0
      call remove(self._state, idx)
    endif
  endfor
endfunction "}}}

function! s:tree._treeExpand(xpos, ypos) "{{{
  let path = self._getPathName(a:xpos, a:ypos)
  " first get all subdirectories
  let nodelist = self.GetSubNodes(path)
  call self._appendSubNodes(a:xpos, a:ypos, nodelist)
  if a:xpos > -1
    call add(self._state, path)
  endif
endfunction "}}}

function! s:tree._appendSubNodes(xpos, ypos, nodeList) "{{{
  call self._window.Unlock()
  " turn + into -
  if a:ypos != 1 
    if getline(a:ypos)[a:xpos] == '+'
      normal! r-
    else
      normal! h"_xi-
    endif 
  endif 
  let ini_path = self._getPathName(a:xpos, a:ypos)
  let nodeList = a:nodeList
  let row = a:ypos
  while len(nodeList) > 0
    " get next line
    let entry = remove(nodeList, 0)
    let path = ini_path . (self.path_separator) . entry
    " add to tree 
    if entry != "" 
      if self.IsLeaf(path) 
        let entry = self._spaceString(a:xpos+2) . entry
      else
        let entry = self._spaceString(a:xpos+1) . "+" . entry
      endif
      call append(row,entry)
      let row = row+1
    endif
  endwhile
  call self._window.Lock()
endfunction "}}}

function! s:tree._spaceString(width) "{{{
  return vorax#utils#StringFiller(' ', a:width)
endfunction "}}}

function! s:tree._treeNodeAction(xpos, ypos) "{{{
  if getline(a:ypos)[a:xpos] == '+'
    call self._treeExpand(a:xpos, a:ypos)
  elseif getline(a:ypos)[a:xpos] == '-'
    call self._treeCollapse(a:xpos, a:ypos)
  endif
endfunction "}}}

function! s:tree._isTreeNode(xpos, ypos) "{{{
  if getline(a:ypos)[a:xpos] =~ '[+-]'
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:tree._getPathName(xpos, ypos) "{{{1
  let xpos = a:xpos
  let ypos = a:ypos
  " check for directory..
  if getline(ypos)[xpos] =~ "[+-]"
    let path = self.path_separator.strpart(getline(ypos), xpos + 1, col('$'))
  else
    " otherwise filename
    let path = self.path_separator.strpart(getline(ypos), xpos, col('$'))
    let xpos = xpos-1
  endif "}}}2
  " walk up tree and append subpaths
  let row = ypos-1
  let indent = xpos
  while indent > 0
    " look for prev ident level
    let indent = indent-1
    while getline(row)[indent] != '-'
      let row = row-1
      if row == 0
        return ""
      endif 
    endwhile 
    " subpath found, append
    let path = self.path_separator . 
          \ strpart(getline(row), indent + 1, strlen(getline(row))) 
          \ . path
  endwhile 
  " finally add base path
  if a:ypos > 1
    let path = getline(1) . path
  endif
  return path
endfunction "}}}1

function! s:tree._treeCollapse(xpos, ypos) "{{{
  call self._window.Unlock()
  " turn - into +, go to next line
  let crr_line = line('.')
  let path = self._getPathName(a:xpos, a:ypos)
  let entry = substitute(getline(a:ypos),'\m^\s*+', '', '')
  if self.IsLeaf(path)
    normal! ^r j
  else
    normal! ^r+j
  endif
  " delete lines til next line with same indent
  while (getline ('.')[a:xpos+1] =~ '[ +-]')
    norm! "_dd
    if line('$') == a:ypos
      break
    endif
  endwhile
  " go up again
  if crr_line != line('$')
    normal! k
  endif
  call self._window.Lock()
  for idx in range(len(self._state))
    if self._state[idx] == path
      call remove(self._state, idx)
      break
    endif
  endfor
endfunction "}}}

function! s:tree._expandCurrentNode() "{{{
  let crr_pos = getpos(".")
  normal! ^
  let xpos = col('.') - 1
  let ypos = line('.')
  let node = self._getPathName(xpos, ypos)
  call self._treeExpand(xpos, ypos)
  call setpos('.', crr_pos) 
endfunction "}}}

function! s:tree._onClick() "{{{
  let save_pos = getpos(".")
  normal! 1|g^
  let xpos = col('.') - 1
  let ypos = line('.')
  let path = self._getPathName(xpos, ypos)
  if self.IsLeaf(path)
    call setpos('.', save_pos)
    call self.OpenNode(path)
  else
    call self._treeNodeAction(xpos, ypos)
  end
endfunction "}}}

function! s:OpenNode(instance)"{{{
  let tree = s:instances[a:instance]
  call tree._onClick()
endfunction"}}}

