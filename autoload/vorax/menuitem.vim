" File:        autoload/vorax/menu_item.vim
" Description: A menu item implementation. Havely inspired by
"              NERDTree plugin:
"
"              https://github.com/scrooloose/nerdtree
"
"							 All credits go to Scrooloose.
" License:     see LICENSE.txt

let s:MenuItem = {}

function! vorax#menuitem#Create(options)
    let newMenuItem = copy(s:MenuItem)

    let newMenuItem.text = a:options['text']
    let newMenuItem.shortcut = a:options['shortcut']
    let newMenuItem.children = []

    let newMenuItem.isActiveCallback = -1
    if has_key(a:options, 'isActiveCallback')
        let newMenuItem.isActiveCallback = a:options['isActiveCallback']
    endif

    let newMenuItem.callback = -1
    if has_key(a:options, 'callback')
        let newMenuItem.callback = a:options['callback']
    endif

    if has_key(a:options, 'parent')
        call add(a:options['parent'].children, newMenuItem)
    else
        call add(s:MenuItem.All(), newMenuItem)
    endif

    return newMenuItem
endfunction


function! s:MenuItem.All()
    if !exists("s:menuItems")
        let s:menuItems = []
    endif
    return s:menuItems
endfunction

function! s:MenuItem.AllEnabled()
    let toReturn = []
    for i in s:MenuItem.All()
        if i.enabled()
            call add(toReturn, i)
        endif
    endfor
    return toReturn
endfunction

function! s:MenuItem.CreateSeparator(options)
    let standard_options = { 'text': '--------------------',
                \ 'shortcut': -1,
                \ 'callback': -1 }
    let options = extend(a:options, standard_options, "force")

    return s:MenuItem.Create(options)
endfunction

function! s:MenuItem.CreateSubmenu(options)
    let standard_options = { 'callback': -1 }
    let options = extend(a:options, standard_options, "force")

    return s:MenuItem.Create(options)
endfunction

function! s:MenuItem.enabled()
    if self.isActiveCallback != -1
        return {self.isActiveCallback}()
    endif
    return 1
endfunction

function! s:MenuItem.execute()
    if len(self.children)
        let mc = s:MenuController.New(self.children)
        call mc.showMenu()
    else
        if self.callback != -1
            call {self.callback}()
        endif
    endif
endfunction

function! s:MenuItem.isSeparator()
    return self.callback == -1 && self.children == []
endfunction

function! s:MenuItem.isSubmenu()
    return self.callback == -1 && !empty(self.children)
endfunction

