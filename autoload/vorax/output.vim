" File:        voraxlib/output.vim
" Author:      Alexandru Tică
" Description: Implements the output window of Vorax.
" License:     see LICENSE.txt

let s:name = "__VORAX_OUTPUT__"
let s:read_chunk_size = 30000
let s:first_chunk = 0
let s:vorax_executing = 0

" The type of funnel:
"   0 = no funnel
"   1 = vertical
"   2 = pagezip
"   3 = tablezip
let s:funnel = g:vorax_output_window_default_funnel

function! vorax#output#Open() abort " {{{
  let splitLocation = g:vorax_output_window_position ==# "top" ? "topleft" : "botright"
  let splitSize = g:vorax_output_window_size
  let outputBufNo = bufnr(s:name)

  if outputBufNo == -1 
    silent! exec splitLocation . ' ' . splitSize . ' new'
    silent! exec "edit " . s:name
  else
    let winnr = bufwinnr(outputBufNo)
    if winnr == -1
      silent! exec splitLocation . ' ' . splitSize . ' split'
      silent! exec "buffer " . s:name
    else
      exec winnr . 'wincmd w'
    endif
  endif

  call s:ConfigureBuffer()
endfunction " }}}

function! vorax#output#SetFunnel(type) abort "{{{
  let s:funnel = a:type
endfunction "}}}

function! vorax#output#GetFunnel() abort "{{{
  return s:funnel
endfunction "}}}

function! vorax#output#Close() abort " {{{
  let outputBufNo = bufnr(s:name)

  if outputBufNo != -1 
    let winnr = bufwinnr(outputBufNo)
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
endfunction " }}}

function! vorax#output#Spit(text) abort " {{{
  call vorax#output#Open()
  normal! G
  let lines = split(a:text, '\n', 1)
  call VORAXDebug("vorax#output#Spit: " . string(lines))
  let last_line = line('$')
  if s:first_chunk && 
        \ len(lines) > 1 && 
        \ getline(last_line) =~ '\m^\s*$' && 
        \ lines[0] == "" && 
        \ len(lines) > 0
    " just a little tweak to get rid of the first empty line
    " in case the last line from the output window has no content.
    call remove(lines, 0)
  endif
  if len(lines) > 0
    call setline(last_line, getline(last_line) . lines[0])
    call append(last_line, lines[1:])
    normal! G
  endif
endfunction " }}}

function! vorax#output#Clear() abort " {{{
  let outputBufNo = bufnr(s:name)
  if outputBufNo != -1 
    let winnr = bufwinnr(outputBufNo)
    if winnr == -1
      exec "bunload! " . outputBufNo
    else
      let crr_win = winnr()
      exec winnr . 'wincmd w'
      normal! gg"_dG
      exec crr_win . 'wincmd w'
    endif
  endif
endfunction " }}}

function! vorax#output#IsWaitingForData() abort"{{{
	return s:vorax_executing
endfunction"}}}

function! vorax#output#SpitterStart() abort " {{{
  let s:vorax_executing = 1
  let s:save_ut = &ut
  set ut=50
  if !g:vorax_output_window_sticky_cursor
    let s:originating_window = winnr()
  endif
  call vorax#output#Open()
  let s:first_chunk = 1
  if !g:vorax_output_window_append
    call vorax#output#Clear()
  endif
  au VoraX CursorHold <buffer> call vorax#output#FetchAndSpit()
endfunction " }}}

function! vorax#output#SpitterStop() abort " {{{
  call vorax#output#Open()
  au! VoraX CursorHold <buffer>
  if !g:vorax_output_window_sticky_cursor
    exe s:originating_window.'wincmd w'
  endif
  call vorax#sqlplus#UpdateSessionOwner()
  if exists("s:save_ut")
		let &ut = s:save_ut
	endif
  let s:vorax_executing = 0
endfunction " }}}

function! vorax#output#FetchAndSpit() abort " {{{
  try
    if vorax#ruby#SqlplusEofOutput() 
      call vorax#output#SpitterStop()
      " clear the throbber message
      echom ""
      redraw
    else
      let chunk = vorax#ruby#SqlplusReadOutput(s:read_chunk_size)
      call vorax#output#Spit(chunk)
      " visual feedback to the user please
      redraw
    endif
    let s:first_chunk = 0
    call feedkeys("f\e")
  catch /^VRX-02/
    call vorax#sqlplus#WarnCrash()
    call vorax#output#SpitterStop()
  endtry
endfunction " }}}

function! vorax#output#Toggle() abort " {{{
  let outputBufNo = bufnr(s:name)
  if outputBufNo == -1 
    call vorax#output#Open()
  else
    let winnr = bufwinnr(outputBufNo)
    if winnr == -1
      call vorax#output#Open()
    else
      call vorax#output#Close()
    endif
  endif
endfunction " }}}

function! vorax#output#ToggleFunnel(type) abort "{{{
  if (a:type == s:funnel) && (a:type != 0)
    " toggle OFF
    let funnel = 0
  else
    let funnel = a:type
  endif
  call vorax#output#SetFunnel(funnel)
  if funnel == 0
    echo 'Genuine SqlPlus output ON.'
  elseif funnel == 1
    echo 'Vertical output ON.'
  elseif funnel == 2
    echo 'Page compression ON.'
  elseif funnel == 3
    echo 'Table compression ON.'
  endif
endfunction "}}}

function! vorax#output#ToggleAppend() abort"{{{
  let g:vorax_output_window_append = !g:vorax_output_window_append
  if g:vorax_output_window_append
    echo 'Append mode ON'
  else
    echo 'Append mode OFF'
  endif
endfunction"}}}

function! vorax#output#ToggleSticky() abort"{{{
  let g:vorax_output_window_sticky_cursor = !g:vorax_output_window_sticky_cursor
  if g:vorax_output_window_sticky_cursor
    echo 'Sticky mode ON'
  else
    echo 'Sticky mode OFF'
  endif
endfunction"}}}

function! vorax#output#Abort() abort"{{{
  try
    if vorax#ruby#SqlplusIsInitialized() &&
          \ vorax#ruby#SqlplusIsAlive() &&
          \ vorax#ruby#SqlplusBusy()
      call vorax#output#ShowCancellingMessage()
      let cancelled = vorax#ruby#SqlplusCancel()
      if !vorax#ruby#SqlplusIsAlive()
        throw 'VRX-02'
      end
      if cancelled
        call vorax#output#Spit("\n*** Cancelled! ***")
      endif
    endif
  catch /^VRX-02/
    let reconnected = ""
    if g:vorax_auto_connect
      let sqlplus_session_props = vorax#sqlplus#Properties()
      call vorax#sqlplus#Initialize()
      call vorax#sqlplus#ExecImmediate("connect " . sqlplus_session_props['connstr'])
      let reconnected = " and reconnected "
    endif
    call vorax#output#Spit("\n*** Session aborted" . reconnected . "! ***")
    call vorax#sqlplus#UpdateSessionOwner()
    echo
  endtry
endfunction"}}}

function! vorax#output#ShowCancellingMessage()"{{{
  redraw
  echo 'Cancelling... Press "K" to abort the session. '
endfunction"}}}

function! vorax#output#AskUser() abort"{{{
  if vorax#ruby#SqlplusIsInitialized() && 
        \ vorax#ruby#SqlplusIsAlive() &&
        \ vorax#ruby#SqlplusBusy()
    let prompt = getline('$')
    let answer = input(prompt)
    call vorax#output#Spit("\n")
    call vorax#ruby#SqlplusSendText(answer . "\n")
  endif
endfunction"}}}

function! vorax#output#StatusLine() abort"{{{
  let props = vorax#sqlplus#Properties()
  if vorax#ruby#SqlplusIsInitialized() &&
        \ vorax#ruby#SqlplusIsAlive() && 
        \ vorax#ruby#SqlplusBusy()
    " just spin throbber
    let throbber = '%3*' . vorax#utils#Throbber() . '%*'
  else
    let throbber = ' '
  endif
  let conn_color = (props['privilege'] != '' ? '%1*' : '%2*')
  let session_owner = conn_color . ' ' . vorax#sqlplus#SessionOwner() . ' %*'
  " current formatting
  if s:funnel == 0
    let format = ''
  elseif s:funnel == 1
    let format = 'VERTICAL'
  elseif s:funnel == 2
    let format = 'PAGEZIP'
  elseif s:funnel == 3
    let format = 'TABLEZIP'
  endif
  " append mode
  let append = (g:vorax_output_window_append ? 'APPEND' : '')
  " sticky mode
  let sticky = (g:vorax_output_window_sticky_cursor ? 'STICKY' : '')
  return throbber .
        \ session_owner . 
        \ '%= ' . format . 
        \ ' ' . append .
        \ ' ' . sticky .
        \ ' '
endfunction"}}}

function! s:ConfigureBuffer() abort " {{{
  setlocal winfixheight
  setlocal hidden
  setlocal winfixheight
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal nowrap
  setlocal nospell
  setlocal nonu
  setlocal cursorline
  setlocal modifiable
  setlocal nolist
  setlocal noreadonly
  setlocal nobuflisted
  setlocal isk+=$
  setlocal isk+=#
  exe 'setlocal statusline=' . g:vorax_output_window_statusline
  
  " set local commands
  command! -n=0 -bar VORAXOutputClear :call vorax#output#Clear()
  command! -n=0 -bar VORAXOutputVertical :call vorax#output#ToggleFunnel(1)
  command! -n=0 -bar VORAXOutputPagezip :call vorax#output#ToggleFunnel(2)
  command! -n=0 -bar VORAXOutputTablezip :call vorax#output#ToggleFunnel(3)
  command! -n=0 -bar VORAXOutputToggleAppend :call vorax#output#ToggleAppend()
  command! -n=0 -bar VORAXOutputToggleSticky :call vorax#output#ToggleSticky()
  command! -n=0 -bar VORAXOutputAskUser :call vorax#output#AskUser()
  command! -n=0 -bar VORAXOutputAbort :call vorax#output#Abort()

  " highlight errors
  exe 'match ' . g:vorax_output_window_hl_error . ' /^\(ORA-\|SP[0-9]\?-\).*/'

  " ESC for cancelling the currently executing statement
  exe 'nnoremap <buffer> <silent>' . g:vorax_output_abort_key . ' :VORAXOutputAbort<CR>'

endfunction " }}}

function! s:DiscardLastSqlprompt() abort " {{{
  call vorax#output#Open()
  if s:funnel > 0
    " In HTML mode, Sqlplus behaves differently: a <BR> is echoed after the
    " sqlprompt, which means that, in order to get rid of the last sqlprompt,
    " we have to remove also the last but one line.
    call setline(line("$")-1, "")
  endif
  normal! G"_dd
endfunction " }}}

