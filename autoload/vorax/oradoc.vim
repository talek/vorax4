" File:        voraxlib/oradoc.vim
" Author:      Alexandru Tică
" Description: Oracle Doc
" License:     see LICENSE.txt

let s:index_location = g:vorax_homedir . '/oradoc'

let s:oradoc_win = vorax#window#New(
      \ {'name': '/__ORADOC__',
      \  'style' : g:vorax_oradoc_win_style,
      \  'side' : g:vorax_oradoc_win_side,
      \  'size' : g:vorax_oradoc_win_size,
      \  'span' : 1,
      \  'min_size' : 5})

function! s:oradoc_win.AfterOpen()
  let &ft="oradocvorax"
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
  setlocal conceallevel=3
  " define key mappings
  nnoremap <silent> <buffer> o :call <SID>OpenDoc()<CR>
  nnoremap <silent> <buffer> <CR> :call <SID>OpenDoc()<CR>
  nnoremap <silent> <buffer> q :call <SID>CloseDocWin()<CR>
endfunction

function! vorax#oradoc#Books(doc_folder)
  echo 'Searching ' . a:doc_folder 
  call vorax#ruby#DisplayBooks(a:doc_folder)
endfunction

function! vorax#oradoc#CreateIndex(doc_folder)
  if !exists('g:vorax_oradoc_index_only')
    let index_only = ''
  else
    let index_only = g:vorax_oradoc_index_only
  endif
  call vorax#ruby#CreateDocIndex(a:doc_folder,
        \ s:index_location,
        \ index_only)
endfunction

function! vorax#oradoc#Search(...)
  if a:0 == 0
    let what = input('Oradoc search: ')
  else
    let what = join(a:000, " ")
  endif
  echo 'Searching... '
  if exists('g:vorax_oradoc_max_results')
    let results = vorax#ruby#OradocSearch(s:index_location, what,
          \ g:vorax_oradoc_max_results)
  else    
    let results = vorax#ruby#OradocSearch(s:index_location, what)
  endif
  if len(results) > 0
    " we have something to display
    if !s:oradoc_win.IsOpen()
      call s:oradoc_win.Open()
    endif
    call s:oradoc_win.Focus()
    call s:oradoc_win.Clear()
    call s:oradoc_win.Unlock()
    " populate
    let items = []
    for result in results
      call add(items, 
            \ substitute(result["title"], '\s*$', '', 'g') . ": " . result["book"])
    endfor
    call append(0, items)
    let b:results = results
    normal! gg
    call s:oradoc_win.Lock()
    redraw | echo 'Done.'
  else
    echo 'Sorry, no doc references found!'
  endif
endfunction

function! s:CloseDocWin()
  call s:oradoc_win.Close()
endfunction

function! s:OpenDoc()
  if line('.') <= len(b:results)
    let item = b:results[line('.') - 1]
    let doc_file = item['file']
    if !exists('g:vorax_oradoc_open_cmd')
      echo "Opening document: " . doc_file
      echo "Don't know how to open the doc file. Please define the g:vorax_oradoc_open_cmd variable."
    else
      let cmd = substitute(g:vorax_oradoc_open_cmd, '%u', doc_file, 'g')
      call VORAXDebug('open oradoc with: ' . cmd)
      exe "silent! !" . cmd
      redraw!
    endif
  endif
endfunction
