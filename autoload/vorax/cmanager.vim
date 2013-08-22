" File:        voraxlib/cmanager.vim
" Author:      Alexandru Tică
" Description: Provides the Vorax connection manager.
" License:     see LICENSE.txt

" Define the connections tree
let s:tree = vorax#tree#New(
			\ {'root' : 'CONNECT PROFILES',
			\  'name' : '__VORAX_CONNECTIONS__',
			\  'style': 'vertical', 
			\  'side': g:vorax_cmanager_side, 
			\  'size': g:vorax_cmanager_size, 
			\  'min_size': 10,
			\  'span': 1})

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
	let path = s:tree.GetPathUnderCursor()
	if s:tree.IsLeaf(path)
		call s:ProfileMenu().showMenu()
  else
		if path ==? s:tree.path_separator . s:tree.root
			call s:RootMenu().showMenu()
		else
			call s:CategoryMenu().showMenu()
		endif
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
		" ask for category
		if !exists('default_category')
			let default_category = split(s:tree.GetPathUnderCursor(), s:tree.path_separator)[-1]
			if default_category == s:tree.root
				let default_category = ''
			endif
		endif
		let category = input('Assign to catgory: ', default_category)
		let parts = vorax#ruby#ParseConnectionString(profile)
		if !vorax#utils#IsEmpty(parts['password'])
			if !s:PmUnlock()
				call vorax#utils#SpitWarn("\nSorry! Invalid password")
				return
			endif
		endif
	  if s:IsWalletConnection(parts)
	  	let profile_id = '/@' . parts['db']
	  else
			let profile_id = parts['user'] . '@' . parts['db']
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
	let new_category=input('Category: ', category)
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

function! s:tree.ConfigureOptions() "{{{
	setlocal nonu
	setlocal cursorline
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

function! s:EnterMasterPwd() "{{{
  let pwd = inputsecret('Enter master password: ')
	return pwd
endfunction "}}}

function! s:RootMenu() "{{{
	let add_profile = vorax#menuitem#Create({'text': '(A)dd profile', 'shortcut' : 'a', 'callback': 'vorax#cmanager#AddProfile'})
	let unlock = vorax#menuitem#Create({'text': '(U)nlock repository', 'shortcut' : 'u', 'callback' : 'vorax#cmanager#UnlockRepository'})
	let change_pwd = vorax#menuitem#Create({'text': '(C)hange password', 'shortcut' : 'c', 'callback' : 'vorax#cmanager#ChangePassword'})
	let items = [add_profile]
	if vorax#ruby#IsPmUnlocked()
		call add(items, change_pwd)
	else
		call add(items, unlock)
	endif
	let root_menu = vorax#menu#Create(items, 'Profiles menu. ')
	return root_menu
endfunction "}}}

function! s:CategoryMenu() "{{{
	if !exists('s:conn_cat_menu')
		let add_profile = vorax#menuitem#Create({'text': '(A)dd profile', 'shortcut' : 'a', 'callback': 'vorax#cmanager#AddProfile'})
		let rename_ctg = vorax#menuitem#Create({'text': '(R)ename category', 'shortcut' : 'r', 'callback' : 'vorax#cmanager#RenameCategory'})
		let remove_all = vorax#menuitem#Create({'text': '(D)elete category including all profiles', 'shortcut' : 'd', 'callback' : 'vorax#cmanager#RemoveCategory'})
		let items = [add_profile, rename_ctg, remove_all]
		let s:conn_cat_menu = vorax#menu#Create(items, 'Profiles menu. ')
	endif
	return s:conn_cat_menu
endfunction "}}}

function! s:ProfileMenu() "{{{
	if !exists('s:conn_menu')
		let change_profile = vorax#menuitem#Create({'text': '(C)hange profile', 'shortcut' : 'c', 'callback' : 'vorax#cmanager#ChangeProfile'})
		let remove_profile = vorax#menuitem#Create({'text': '(R)emove profile', 'shortcut' : 'r', 'callback' : 'vorax#cmanager#RemoveProfile'})
		let show_profile = vorax#menuitem#Create({'text': '(S)how profile', 'shortcut' : 's', 'callback' : 'vorax#cmanager#ShowProfile'})
		let items = [change_profile, remove_profile, show_profile]
		let s:conn_menu = vorax#menu#Create(items, 'Profiles menu. ')
	endif
	return s:conn_menu
endfunction "}}}

function! s:IsWalletConnection(parts)
	let parts = a:parts
	if parts['prompt_for'] == '' &&
				\ parts['user'] == '' &&
				\ parts['password'] == '' &&
				\ parts['db'] != ''
		return 1
	else
		return 0
	endif
endfunction
