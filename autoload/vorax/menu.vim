" File:        voraxlib/menu.vim
" Description: Provides implementation for a basic menu. Havily
"              inspired by NERDTree plugin:
"
"              https://github.com/scrooloose/nerdtree
"
"              All credits go to Scrooloose.
" License:     see LICENSE.txt

let s:MenuController = {}

function! vorax#menu#Create(menuItems, banner)
  let newMenuController =  copy(s:MenuController)
  let newMenuController.banner = a:banner
  if a:menuItems[0].isSeparator()
    let newMenuController.menuItems = a:menuItems[1:-1]
  else
    let newMenuController.menuItems = a:menuItems
  endif
  return newMenuController
endfunction

function! s:MenuController.allEnabled()
  let enabled_items = []
  for i in self.menuItems
    if i.enabled()
      call add(enabled_items, i)
    endif
  endfor
  return enabled_items
endfunction

function! s:MenuController.showMenu()
  let self.enabledItems = self.allEnabled()
  if len(self.enabledItems) == 0
    return
  endif
  call self._saveOptions()

  try
    let self.selection = 0

    let done = 0
    while !done
      redraw!
      call self._echoPrompt()
      let key = nr2char(getchar())
      let done = self._handleKeypress(key)
    endwhile
  finally
    call self._restoreOptions()
  endtry

  if self.selection != -1
    let m = self._current()
    call m.execute()
  endif
endfunction

function! s:MenuController._echoPrompt()
  let banner = self.banner . "Use j/k/enter and the shortcuts indicated"
  echo banner
  echo vorax#utils#StringFiller("=", len(banner))

  for i in range(0, len(self.enabledItems)-1)
    if self.selection == i
      echo "> " . self.enabledItems[i].text
    else
      echo "  " . self.enabledItems[i].text
    endif
  endfor
endfunction

function! s:MenuController._current()
  return self.enabledItems[self.selection]
endfunction

function! s:MenuController._handleKeypress(key)
  if a:key == 'j'
    call self._cursorDown()
  elseif a:key == 'k'
    call self._cursorUp()
  elseif a:key == nr2char(27) "escape
    let self.selection = -1
    return 1
  elseif a:key == "\r" || a:key == "\n" "enter and ctrl-j
    return 1
  else
    let index = self._nextIndexFor(a:key)
    if index != -1
      let self.selection = index
      if len(self._allIndexesFor(a:key)) == 1
        return 1
      endif
    endif
  endif

  return 0
endfunction

function! s:MenuController._allIndexesFor(shortcut)
  let toReturn = []

  for i in range(0, len(self.enabledItems)-1)
    if self.enabledItems[i].shortcut == a:shortcut
      call add(toReturn, i)
    endif
  endfor

  return toReturn
endfunction

function! s:MenuController._nextIndexFor(shortcut)
  for i in range(self.selection+1, len(self.enabledItems)-1)
    if self.enabledItems[i].shortcut == a:shortcut
      return i
    endif
  endfor

  for i in range(0, self.selection)
    if self.enabledItems[i].shortcut == a:shortcut
      return i
    endif
  endfor

  return -1
endfunction

function! s:MenuController._setCmdheight()
  let &cmdheight = len(self.enabledItems) + 3
endfunction

function! s:MenuController._saveOptions()
  let self._oldLazyredraw = &lazyredraw
  let self._oldCmdheight = &cmdheight
  set nolazyredraw
  call self._setCmdheight()
endfunction

function! s:MenuController._restoreOptions()
  let &cmdheight = self._oldCmdheight
  let &lazyredraw = self._oldLazyredraw
endfunction

function! s:MenuController._cursorDown()
  let done = 0
  while !done
    if self.selection < len(self.enabledItems)-1
      let self.selection += 1
    else
      let self.selection = 0
    endif

    if !self._current().isSeparator()
      let done = 1
    endif
  endwhile
endfunction

function! s:MenuController._cursorUp()
  let done = 0
  while !done
    if self.selection > 0
      let self.selection -= 1
    else
      let self.selection = len(self.enabledItems)-1
    endif

    if !self._current().isSeparator()
      let done = 1
    endif
  endwhile
endfunction
