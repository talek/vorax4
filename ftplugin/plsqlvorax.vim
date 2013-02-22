" File:        ftplugin/plsqlvorax.vim
" Author:      Alexandru Tică
" Description: Code automatically executed when a vorax PL/SQL file is open
" License:     see LICENSE.txt

let b:crr_changedtick = 0

if g:vorax_folding_enable

  function! s:SaveOpenFolds()"{{{
    if exists('b:descriptor')
      for element in b:descriptor
        if foldlevel(element["start_pos"]) > 0
          if foldclosed(element["start_pos"]) != -1
            let element['open'] = 0
          else
            let element['open'] = 1
          endif
        else
          let element['open'] = 0
        endif
      endfor
    endif
  endfunction"}}}

  function! s:ComputeFoldsStructure()"{{{
    let b:descriptor = sort(vorax#ruby#PlsqlRegions(vorax#utils#BufferContent()), 'vorax#utils#CompareRegionsByLevelDesc')
    for element in b:descriptor
      let element["start_pos"] = byte2line(element["start_pos"] + 1)
      let element["end_pos"] = byte2line(element["end_pos"])
    endfor
    call s:SaveOpenFolds()
  endfunction"}}}

  function! s:CreateFolds(force)"{{{
    let state = winsaveview()
    if a:force || b:crr_changedtick != b:changedtick
      " only if changes in the buffer occured
      call s:ComputeFoldsStructure()
      let b:crr_changedtick = b:changedtick
			if exists('b:descriptor')
				" remove existing folds
				normal! zE
				" remark folding points
				for element in b:descriptor
					if element["start_pos"] < element["end_pos"]
						try
							exe element["start_pos"] . "," . element["end_pos"] . "fo"
							if element['open'] || (line('.') >= element["start_pos"] && line('.') <= element["end_pos"])
								" restore previous opened folds and keep the current fold open
								exe element["start_pos"] . "," . element["end_pos"] . "foldo"
							endif
						catch /^Vim\%((\a\+)\)\=:E490/
							" might happen if the previous regions were
							" incorrectly defined on an syntactically wrong PLSQL code
						endtry
					endif
				endfor
			endif
		endif
    call winrestview(state)
  endfunction"}}}

  setlocal foldmethod=manual
  setlocal foldcolumn=2

  call s:CreateFolds(1)
  "autocmd InsertLeave <buffer> call s:CreateFolds(0)
  autocmd CursorHold <buffer> call s:CreateFolds(0)

  if g:vorax_folding_initial_state ==? 'all_close'
    normal! zM
  elseif g:vorax_folding_initial_state ==? 'all_open'
    normal! zR
  endif

endif

" set Vorax completion function
if g:vorax_omni_enable
  setlocal omnifunc=vorax#omni#Complete
endif

if exists('*VORAXAfterPlsqlBufferLoad')
	" Execute hook
	call VORAXAfterPlsqlBufferLoad()
endif

" signal that everything is setup
let b:did_ftplugin = 1
