" Purpose:  Vim syntax file
" Language: Voraxconnection profiles
" Author:   Alexandru Tica

if !exists('b:current_syntax')
  syn match Directory  /^\s*\(-\|+\).*/
endif

let b:current_syntax = "connvorax"

