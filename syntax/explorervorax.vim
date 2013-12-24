" Purpose:  Vim syntax file
" Language: Vorax DB explorer syntax
" Author:   Alexandru Tica

if !exists('b:current_syntax')
  syn match Directory  /^\s*\(-\|+\).*/
  syn match Error  /.\{-}\( \[INVALID\]\)\@=/
  syn match Ignore  /\[INVALID\]$/ conceal
endif

let b:current_syntax = "explorervorax"


