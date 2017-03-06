set background=dark
highlight clear
if exists("syntax on")
  syntax reset
endif
let g:colors_name = "gil"

" Greys
hi Normal          ctermfg=250 ctermbg=235
hi NonText         ctermfg=236 ctermbg=NONE
hi Special         ctermfg=253 ctermbg=NONE
hi Constant        ctermfg=249 ctermbg=NONE
hi htmlTagName     ctermfg=249 ctermbg=NONE
hi Identifier      ctermfg=239 ctermbg=NONE
hi Boolean         ctermfg=243 ctermbg=NONE cterm=NONE
hi Type            ctermfg=249 ctermbg=NONE
hi Function        ctermfg=255 ctermbg=NONE cterm=bold
hi Repeat          ctermfg=244 ctermbg=NONE
hi linenr          ctermfg=241 ctermbg=235
hi CursorLineNR    ctermfg=241 ctermbg=234
hi Visual          ctermfg=250 ctermbg=237 cterm=italic
hi SpecialKey      ctermfg=236 ctermbg=NONE
hi MatchParen      ctermfg=253 ctermbg=242
hi Pmenu           ctermfg=250 ctermbg=237
hi PmenuSel        ctermfg=235 ctermbg=111
hi ColorColumn                 ctermbg=236
hi CursorLine                  ctermbg=236 cterm=none
hi VertSplit       ctermfg=235 ctermbg=235
hi SignColumn      ctermfg=235 ctermbg=235
hi IncSearch       ctermfg=255 ctermbg=235 cterm=NONE
hi Search          ctermfg=250 ctermbg=235 cterm=underline
hi NERDTreeFile    ctermfg=246

hi Comment         ctermfg=10  ctermbg=NONE cterm=bold
hi Statement       ctermfg=7   ctermbg=NONE cterm=NONE
hi String          ctermfg=4   ctermbg=NONE
hi Number          ctermfg=8   ctermbg=NONE

hi Error           ctermfg=1   ctermbg=NONE
hi TODO            ctermfg=10  ctermbg=NONE cterm=italic
hi Operator        ctermfg=255 ctermbg=NONE

hi PreProc         ctermfg=243 ctermbg=NONE

" False None True
hi pythonStatement   ctermfg=255
" as assert break continue del exec global
hi pythonStatement   ctermfg=255
" lambda nonlocal pass print return with yield
hi pythonStatement   ctermfg=255
" class def nextgroup=pythonFunction skipwhite
hi pythonStatement   ctermfg=255
" elif else if
hi pythonConditional ctermfg=255
" for while
hi pythonRepeat      ctermfg=255
" and in is not or
hi pythonOperator    ctermfg=255
" except finally raise try
hi pythonException   ctermfg=255
" from import
hi pythonInclude     ctermfg=255
" async await
hi pythonAsync       ctermfg=255


hi link character       constant
hi link number          constant
hi link boolean         constant
hi link Float           Number
hi link Conditional     Repeat
hi link Label           Statement
hi link Keyword         Statement
hi link Exception       Statement
hi link Include         PreProc
hi link Define          PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link htmlTag         Special
hi link Tag             Special
hi link SpecialChar     Special
hi link Delimiter       Special
hi link SpecialComment  Special
hi link Debug           Special
hi link NERDTreeDir     Special


" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
    exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
    exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('py',  'green', 'none', 'green', '#151515')
