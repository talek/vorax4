" File:        voraxlib/output.vim
" Author:      Alexandru Tică
" Description: Implements the output window of Vorax.
" License:     see LICENSE.txt

let s:name = "/__VORAX_OUTPUT__"
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
      return
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
  if len(lines) > 1 && lines[0] != ''
    call VORAXDebug("vorax#output#Spit: " . string(lines))
  endif
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
    if s:first_chunk && g:vorax_output_cursor_on_top
      if lines[0] == ""
        let s:current_line = last_line + 1
      else
        let s:current_line = last_line 
      endif
    endif
    call setline(last_line, getline(last_line) . lines[0])
    call append(last_line, lines[1:])
    normal! G
  endif
endfunction " }}}

function! vorax#output#SpitAll(text) abort "{{{
  call vorax#output#PrepareSpit()
  call vorax#output#Spit(a:text)
  call vorax#output#PostSpit()
endfunction "}}}

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

function! vorax#output#PrepareSpit() abort "{{{
  if !g:vorax_output_window_sticky_cursor
    let s:originating_window = winnr()
  endif
  call vorax#output#Open()
  let s:first_chunk = 1
  if !g:vorax_output_window_append
    call vorax#output#Clear()
  endif
endfunction "}}}

function! vorax#output#SpitterStart() abort " {{{
  let s:vorax_executing = 1
  let s:save_ut = &ut
  set ut=50
  call vorax#output#PrepareSpit()
  au VoraX CursorHold <buffer> call vorax#output#FetchAndSpit()
endfunction " }}}

function! vorax#output#PostSpit() abort "{{{
  call vorax#sqlplus#UpdateSessionOwner()
  if g:vorax_output_show_open_txn
    call vorax#sqlplus#UpdateTransaction()
  endif
  " update dbexplorer
  call vorax#explorer#RefreshRoot()
  call vorax#output#Open()
  if g:vorax_output_cursor_on_top
    exe "normal! " . s:current_line . 'G'
  endif
  if !g:vorax_output_window_sticky_cursor
    if s:originating_window != winnr()
      " Needed when here from the CursorHold event. An autoevent
      " is not trigger from another event, so the BufLeave au
      " will not be triggered.

      " update visible bounds
      call vorax#output#SetVisibleBounds()
      " disable cursorline
      setlocal nocursorline

      exe s:originating_window.'wincmd w'
    endif
  endif
endfunction "}}}

function! vorax#output#SpitterStop() abort " {{{
  call vorax#output#Open()
  au! VoraX CursorHold <buffer>
  call vorax#output#PostSpit()
  let prop = vorax#sqlplus#Properties()
  if filereadable(prop['store_set'])
    call VORAXDebug('vorax#output#SpitterStop(): sp_options='.string(readfile(prop['store_set'], 'b')))
  endif
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
      echo ""
      redraw
    else
      let chunk = vorax#ruby#SqlplusReadOutput(s:read_chunk_size)
      if chunk != ""
        call vorax#output#Spit(chunk)
      endif
      " visual feedback to the user please
      redraw
    endif
    let s:first_chunk = 0
    call feedkeys("f\e", 'n')
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

function! vorax#output#ToggleFullHeading() abort"{{{
  let g:vorax_output_full_heading = !g:vorax_output_full_heading
  if g:vorax_output_full_heading
    echo 'Full heading mode ON'
  else
    echo 'Full heading mode OFF'
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

function! vorax#output#ToggleTop() abort"{{{
  let g:vorax_output_cursor_on_top = !g:vorax_output_cursor_on_top
  if g:vorax_output_cursor_on_top
    echo 'Top mode ON'
  else
    echo 'Top mode OFF'
  endif
endfunction"}}}

function! vorax#output#Abort() abort"{{{
  try
    let sp_props = vorax#sqlplus#Properties()
    if vorax#ruby#SqlplusIsInitialized() &&
          \ vorax#ruby#SqlplusIsAlive() &&
          \ vorax#ruby#SqlplusBusy()
      call vorax#output#ShowCancellingMessage()
      let cancelled = vorax#ruby#SqlplusCancel()
      if !vorax#ruby#SqlplusIsAlive()
        throw 'VRX-02'
      end
      if cancelled
        " it's a good thing to revert to default options
        if filereadable(sp_props['store_set'])
          call vorax#sqlplus#ExecImmediate('@' . sp_props['store_set'])
        endif
        if !vorax#utils#IsEmpty(sp_props['cols_clear'])
          " clear columns if previous formatting was in place
          call vorax#sqlplus#ExecImmediate(sp_props['cols_clear'])
        endif
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
    call vorax#sqlplus#UpdateSessionOwner()
    if vorax#sqlplus#SessionOwner() == '@'
      " reconnected my ass
      let reconnected = ''
    endif
    " clear txn flag
    let sp_props['transaction'] = ''
    call vorax#output#Spit("\n*** Session aborted" . reconnected . "! ***")
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
  " column heading
  let col_head = (g:vorax_output_full_heading ? ' HEADING' : '')
  " append mode
  let append = (g:vorax_output_window_append ? ' APPEND' : '')
  " sticky mode
  let sticky = (g:vorax_output_window_sticky_cursor ? ' STICKY' : '')
  " top mode
  let top = (g:vorax_output_cursor_on_top ? ' TOP' : '')
  " limit rows
  let limit_rows = (exists('g:vorax_limit_rows') ? ' LIMIT=' . g:vorax_limit_rows : '')
  return throbber .
        \ session_owner . 
        \ '%4*' . props['transaction'] . '%*' .
        \ '%= ' . format .
        \ col_head .
        \ append .
        \ top .
        \ sticky .
        \ limit_rows .
        \ ' '
endfunction"}}}

function! vorax#output#ToggleLimitRows() "{{{
  if !exists('g:vorax_limit_rows')
    let val = input('Limit rows to: ', '')
    if val =~ '\m^[0-9]\+$'
      let g:vorax_limit_rows=str2nr(val)
    endif
  else
    unlet g:vorax_limit_rows
  endif
endfunction "}}}

function! vorax#output#GetBufferName() "{{{
  return s:name
endfunction "}}}

function! vorax#output#SetVisibleBounds() "{{{
  let b:vorax_visible_bounds=[line('w0'), line('w$')]
endfunction "}}}

function! s:ConfigureBuffer() abort " {{{
  let &ft="outputvorax"
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
  

  " highlight errors
  exe 'match ' . g:vorax_output_window_hl_error . ' /^\(ORA-\|SP[0-9]\?-\).*/'

  " ESC for cancelling the currently executing statement
  exe 'nnoremap <buffer> <silent>' . g:vorax_output_abort_key . ' :VORAXOutputAbort<CR>'

  " Oradoc keymap
  nnoremap <buffer> <silent> K :call vorax#oradoc#Search(expand('<cWORD>'))<CR>

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

