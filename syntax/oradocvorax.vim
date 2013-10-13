" Purpose:  Vim syntax file
" Language: Vorax oradoc syntax
" Author:   Alexandru Tica

if !exists('b:current_syntax')
  syn match Directory  /^.\{-}: /
endif

let b:current_syntax = "oradocvorax"


