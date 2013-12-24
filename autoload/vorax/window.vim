" File:        voraxlib/window.vim
" Author:      Alexandru Tică
" Description: provides logic for handling Vim windows.
" License:     see LICENSE.txt

let s:window = {
      \ 'name' : '__UNNAMED__',
      \ 'style' : 'vertical',
      \ 'side' : 'left',
      \ 'span' : 1,
      \ 'size' : 10,
      \ 'min_size' : 10
      \ }

function! vorax#window#New(options) "{{{
  let window = copy(s:window)
  call vorax#utils#MergeOptions(window, a:options)
  return window
endfunction "}}}

function! s:window.Open() "{{{
  if self.span
    if (self.side ==? 'top') || (self.side ==? 'left')
      let splitcmd = 'topleft '
    else
      let splitcmd = 'botright '
    end
  else
    let splitcmd = ''
    let state = vorax#utils#GetState('splitright', 'splitbelow')
  end
  if self.style ==? 'vertical'
    let splitcmd .= self.size . 'vnew'
    if !self.span
      if self.side ==? 'left'
        let &splitright = 0
      else
        let &splitright = 1
      endif
    endif
  else
    let splitcmd .= self.size . 'new'
    if !self.span
      if self.side ==? 'top'
        let &splitbelow = 0
      else
        let &splitbelow = 1
      endif
    endif
  endif
  let splitcmd .= ' ' . self.name
  silent exe splitcmd
  if self.style ==? 'vertical'
    exe "setlocal wiw=" . self.min_size
  else
    exe "setlocal wh=" . self.min_size
  endif
  if exists('state')
    exec vorax#utils#SetState(state)
  endif
  call self.AfterOpen()
endfunction "}}}

function! s:window.AfterOpen() "{{{
endfunction "}}}

function! s:window.Toggle() "{{{
  let bufNo = bufnr(self.name)
  if bufNo == -1 
    call self.Open()
  else
    let winnr = bufwinnr(bufNo)
    if winnr == -1
      call self.Open()
    else
      call self.Close()
    endif
  endif
endfunction "}}}

function! s:window.IsOpen() "{{{
  let bufNo = bufnr(self.name)
  if bufNo == -1 
    return 0
  else
    let winnr = bufwinnr(bufNo)
    if winnr == -1
      return 0
    else
      return 1
    endif
  endif
endfunction "}}}

function! s:window.Close() "{{{
  let bufNo = bufnr(self.name)
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
endfunction "}}}

function! s:window.Clear() "{{{
  let state = vorax#utils#GetState('modifiable', 'modified')
  call self.Unlock()
  normal! gg"_dGd
  call vorax#utils#SetState(state)
endfunction "}}}

function! s:window.Lock() "{{{
  setlocal nomodifiable nomodified
endfunction "}}}

function! s:window.Unlock() "{{{
  setlocal modifiable
endfunction "}}}

function! s:window.Focus() "{{{
  if self.IsOpen()
    let wnr = bufwinnr(self.name)
    exe wnr . 'wincmd w'
  else
    call self.Open()
  endif
endfunction "}}}
