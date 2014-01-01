" File:        voraxlib/cmanager.vim
" Author:      Alexandru Tică
" Description: Provides the Vorax connection manager.
" License:     see LICENSE.txt

" Define the connections tree
let s:tree = vorax#tree#New(
      \ {'root' : 'CONNECTION PROFILES',
      \  'name' : '/__VORAX_CONNECTIONS__',
      \  'style': 'vertical', 
      \  'side': g:vorax_cmanager_side, 
      \  'size': g:vorax_cmanager_size, 
      \  'min_size': 10,
      \  'span': 1})

" Registered plugins
let s:plugins = []

" Initialize password manager
call vorax#ruby#PmInit(g:vorax_homedir)

function! vorax#cmanager#Open() abort "{{{
  call s:tree.Open()
endfunction "}}}

function! vorax#cmanager#Close() abort " {{{
  call s:tree.Close()
endfunction " }}}

function! vorax#cmanager#Toggle() abort "{{{
  call s:tree.Toggle()
endfunction "}}}

function! vorax#cmanager#Refresh(...) "{{{
  call s:tree.RebuildTree()
  if a:0 > 0
    let path = a:1
    call s:tree.RevealNode(path)
  endif
endfunction "}}}

function! vorax#cmanager#OpenContextMenu() "{{{
  let menu = s:ContextualMenu()
  if menu != {}
    call menu.showMenu()
  endif
endfunction "}}}

function! vorax#cmanager#AddProfile(...) "{{{
  let default_profile = ''
  if a:0 > 0
    if exists('a:1')
      let default_profile = a:1
    endif
    if exists('a:2')
      let default_category = a:2
    endif
  endif
  let profile = input('Enter profile: ', default_profile)
  if vorax#utils#IsEmpty(profile)
    return
  else
    if s:IsDuplicateProfile(profile)
      call vorax#utils#SpitWarn("\nSorry! A profile with the same name already exists!")
      return
    endif
    " ask for category
    if !exists('default_category')
      let default_category = split(s:tree.GetPathUnderCursor(), s:tree.path_separator)[-1]
      if default_category == s:tree.root
        let default_category = ''
      endif
    endif
    let category = input('Assign to category: ', default_category)
    let parts = vorax#ruby#ParseConnectionString(profile)
    if !vorax#utils#IsEmpty(parts['password'])
      if !s:PmUnlock()
        call vorax#utils#SpitWarn("\nSorry! Invalid password")
        return
      endif
    endif
    if s:IsWalletConnection(parts)
      let profile_id = '/@' . parts['db']
    elseif s:IsOsConnection(parts)
      let profile_id = '/'
    else
      let profile_id = parts['user'] . '@' . parts['db']
    endif
    if parts['role'] != ''
      let profile_id .= ' as ' . parts['role']
    endif
    call vorax#ruby#PmAdd(profile_id,
          \ parts['password'],
          \ category,
          \ 0)
    call vorax#ruby#PmSave()
  endif
  if vorax#utils#IsEmpty(category)
    let path = s:tree.path_separator . s:tree.root . s:tree.path_separator .
          \ profile_id
  else
    let path = s:tree.path_separator . s:tree.root . s:tree.path_separator .
          \ category . s:tree.path_separator .
          \ profile_id
  endif
  call vorax#cmanager#Refresh(path)
endfunction "}}}

function! vorax#cmanager#ChangePassword() "{{{
  let old_pwd = vorax#ruby#PmMasterPwd()
  let new_pwd = vorax#utils#PromptPassword('New Master Password: ')
  if !vorax#utils#IsEmpty(new_pwd)
    call vorax#ruby#PmChangePwd(g:vorax_homedir, old_pwd, new_pwd)
    echo "\nPassword changed!"
  endif
endfunction "}}}

function! vorax#cmanager#ChangeProfile() "{{{
  let crr_path = s:tree.GetPathUnderCursor()
  let parts = split(crr_path, s:tree.path_separator)
  let default_profile = parts[-1]
  let default_category = parts[-2]
  if default_category == s:tree.root
    let default_category = ''
  endif
  call vorax#ruby#PmRemove(default_profile)
  call vorax#cmanager#AddProfile(default_profile, default_category)
endfunction "}}}

function! vorax#cmanager#UnlockRepository() "{{{
  call s:PmUnlock()
endfunction "}}}

function! vorax#cmanager#RemoveProfile() "{{{
  let crr_path = s:tree.GetPathUnderCursor()
  let parts = split(crr_path, s:tree.path_separator)
  let profile = parts[-1]
  let category = parts[-2]
  call vorax#ruby#PmRemove(profile)
  call vorax#ruby#PmSave()
  call vorax#cmanager#Refresh()
endfunction "}}}

function! vorax#cmanager#RenameCategory() "{{{
  let crr_path = s:tree.GetPathUnderCursor()
  let parts = split(crr_path, s:tree.path_separator)
  let category = parts[-1]
  let new_category=input('Category: ', category)
  for profile in vorax#ruby#PmProfiles(category)
    call vorax#ruby#PmEdit(profile, 'category', new_category)
  endfor
  call vorax#ruby#PmSave()
  call vorax#cmanager#Refresh()
endfunction "}}}

function! vorax#cmanager#RemoveCategory() "{{{
  let crr_path = s:tree.GetPathUnderCursor()
  let parts = split(crr_path, s:tree.path_separator)
  let category = parts[-1]
  let categories = copy(vorax#ruby#PmProfiles(category))
  for profile in categories
    call vorax#ruby#PmRemove(profile)
  endfor
  call vorax#ruby#PmSave()
  call vorax#cmanager#Refresh()
endfunction "}}}

function! vorax#cmanager#ShowProfile() "{{{
  let crr_path = s:tree.GetPathUnderCursor()
  let parts = split(crr_path, s:tree.path_separator)
  let profile = parts[-1]
  if vorax#ruby#IsPmProfileWithPassword(profile)
    if !s:PmUnlock()
      call vorax#utils#SpitWarn("\nSorry! Invalid password")
      return
    else
      let conn_parts = vorax#ruby#ParseConnectionString(profile)
      let password = vorax#ruby#PmGetPassword(profile)
      redraw
      echo conn_parts['user'] . '/' . password. 
            \ '@' . conn_parts['db']
    endif
  else
    redraw
    echo profile
  endif
endfunction "}}}

function! vorax#cmanager#CurrentNodeProperties() "{{{
  let path = s:tree.GetPathUnderCursor()
  let parts = split(path, s:tree.path_separator)
  let is_root = (len(parts) == 1 ? 1 : 0)
  if s:tree.IsLeaf(path)
    if parts[-2] == s:tree.root
      let category = ''
    else
      let category = parts[-2]
    endif
    return {'profile': parts[-1], 'category': category, 'root': is_root}
  else
    return {'profile' : '', 'category': parts[-1], 'root': is_root}
  endif
endfunction "}}}

function! vorax#cmanager#PluginEnabled(id) "{{{
  let descriptor = vorax#cmanager#CurrentNodeProperties()
  let plugin = s:plugins[a:id]
  return plugin.IsEnabled(descriptor)
endfunction "}}}

function! vorax#cmanager#PluginCallback(id) "{{{
  let descriptor = vorax#cmanager#CurrentNodeProperties()
  let plugin = s:plugins[a:id]
  return plugin.Callback(descriptor)
endfunction "}}}

function! vorax#cmanager#RegisterPluginItem(item) "{{{
  if vorax#utils#IsEmpty(a:item.shortcut)
    let label = " : " . a:item.text
  else
    let label = a:item.shortcut . ": " . a:item.text
  end
  let menu_item = vorax#menuitem#Create(
        \ {'text': label, 
        \  'shortcut' : a:item.shortcut, 
        \  'callback' : "vorax#cmanager#PluginCallback",
        \  'isActiveCallback' : "vorax#cmanager#PluginEnabled" 
        \ })
  let menu_item.id = len(s:plugins)
  call add(s:plugins, a:item)
  call add(s:cmanager_items, menu_item)
endfunction "}}}

function! vorax#cmanager#ConnectUsingCurrentProfile() "{{{
  let path = s:tree.GetPathUnderCursor()
  call s:tree.OpenNode(path)
endfunction "}}}

function! vorax#cmanager#GetTree() "{{{
  return s:tree
endfunction "}}}

function! s:tree.ConfigureOptions() "{{{
  setlocal nonu
  setlocal cursorline
  setlocal nolist
  setlocal nobuflisted
  setlocal hidden
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal nowrap
  setlocal nospell
  let &ft="connvorax"
  
  " Load plugins here. That's because
  " we want the tree window to be open to let
  " custom plugins to register local mappings
  if !exists('s:cmanager_items')
    let s:cmanager_items = []
    runtime! vorax/plugin/cmanager/**/*.vim
  endif
endfunction "}}}

function! s:tree.ConfigureKeys() "{{{
  noremap <silent> <buffer> m :call vorax#cmanager#OpenContextMenu()<CR>
endfunction "}}}

function! s:tree.GetSubNodes(path) "{{{
  if a:path ==? (self.path_separator . self.root)
    let categories = vorax#ruby#PmCategories()
    return extend(categories, vorax#ruby#PmProfiles(''))
  else
    let category = split(a:path, self.path_separator)[-1]
    return vorax#ruby#PmProfiles(category)
  endif
endfunction "}}}

function! s:tree.IsLeaf(path) "{{{
  let parts = split(a:path, self.path_separator)
  if len(parts) == 1 || len(parts) == 2
    " get profile
    let name = parts[-1]
    for p in vorax#ruby#PmProfiles('')
      if p == name
        return 1
      endif
    endfor
    return 0
  else
    return 1
  endif
endfunction "}}}

function! s:tree.OpenNode(path) "{{{
  let path = a:path
  let profile = split(path, s:tree.path_separator)[-1]
  let password = ''
  if vorax#ruby#IsPmProfileWithPassword(profile)
    if s:PmUnlock()
      let password = vorax#ruby#PmGetPassword(profile)
    else
      call vorax#utils#SpitWarn("\nSorry! Invalid password")
      return
    endif
  endif
  call s:Connect(profile, password)
endfunction "}}}

function! s:Connect(profile, password) "{{{
  let cstr = a:profile
  if !vorax#utils#IsEmpty(a:password)
    let parts = vorax#ruby#ParseConnectionString(a:profile)
    let parts['password'] = a:password
    let cstr = vorax#sqlplus#MergeCstr(parts)
  endif
  call vorax#sqlplus#Connect(cstr)
endfunction "}}}

function! s:EnterMasterPwd() "{{{
  let pwd = inputsecret('Enter master password: ')
  return pwd
endfunction "}}}

function! s:PmUnlock() "{{{
  if vorax#ruby#PmHasKeys(g:vorax_homedir)
    if !vorax#ruby#IsPmUnlocked()
      let master_pwd = s:EnterMasterPwd()
      if vorax#utils#IsEmpty(master_pwd)
        return 0
      else
        call vorax#ruby#PmSetMasterPassword(master_pwd)
        if !vorax#ruby#IsPmUnlocked()
          return 0
        endif
      endif
    endif
  else
    " create the keys
    echo "\nThe password repository is not secured!"
    if confirm('Do you want to secure it now?', "&Yes\n&No", 1) == 1
      let master_pwd = vorax#utils#PromptPassword("Master Password: ")
      if !vorax#utils#IsEmpty(master_pwd)
        call vorax#ruby#PmSecure(g:vorax_homedir, master_pwd)
        call vorax#ruby#PmSetMasterPassword(master_pwd)
      else
        call vorax#utils#SpitWarn("\nThe master password is required!")
        return 0
      endif
    else
      return 0
    endif
  endif
  return 1
endfunction "}}}

function! s:IsDuplicateProfile(profile) "{{{
  for item in vorax#ruby#PmAllProfiles()
    if item == a:profile
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:IsOsConnection(parts) "{{{
  let parts = a:parts
  if parts['user'] == '' &&
        \ parts['password'] == '' &&
        \ parts['db'] == '' &&
        \ parts['role'] != ''
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:IsWalletConnection(parts) "{{{
  let parts = a:parts
  if parts['prompt_for'] == '' &&
        \ parts['user'] == '' &&
        \ parts['password'] == '' &&
        \ parts['db'] != ''
    return 1
  else
    return 0
  endif
endfunction "}}}

function! s:ContextualMenu() "{{{
  if !exists('s:cmanager_menu')
    if len(s:cmanager_items) > 0
      let s:cmanager_menu = vorax#menu#Create(s:cmanager_items, 'Connection Profiles Menu. ')
    else
      return {}
    endif
  endif
  return s:cmanager_menu
endfunction "}}}

