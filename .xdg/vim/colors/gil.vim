set background=dark
highlight clear
if exists("syntax on")
  syntax reset
endif
let g:colors_name = "gil"


" Colors
" 1     Red
" 10    Green
" 214   Yellow
"
" 235   Black
" 235   Super Dark Grey
" 240   Dark Dark Grey
" 245   Dark Grey
" 250   Grey
" 255   Light Grey
"""""


" Greys
hi Normal           ctermfg=250 ctermbg=235   cterm=NONE
hi NonText          ctermfg=235 ctermbg=NONE  cterm=NONE
hi Special          ctermfg=250 ctermbg=NONE  cterm=NONE
hi Constant         ctermfg=250 ctermbg=NONE  cterm=NONE
hi htmlTagName      ctermfg=250 ctermbg=NONE  cterm=NONE
hi Identifier       ctermfg=240 ctermbg=NONE  cterm=NONE
hi Boolean          ctermfg=245 ctermbg=NONE  cterm=bold
hi Type             ctermfg=250 ctermbg=NONE  cterm=NONE
hi Function         ctermfg=255 ctermbg=NONE  cterm=NONE
hi Repeat           ctermfg=245 ctermbg=NONE  cterm=NONE
hi linenr           ctermfg=240 ctermbg=235   cterm=NONE
hi Visual           ctermfg=235 ctermbg=250   cterm=NONE
hi SpecialKey       ctermfg=235 ctermbg=NONE  cterm=NONE
hi MatchParen       ctermfg=250 ctermbg=245   cterm=NONE

hi ColorColumn      ctermfg=NONE ctermbg=236  cterm=NONE
hi Cursor           ctermfg=NONE ctermbg=NONE cterm=NONE
hi CursorLine       ctermfg=NONE ctermbg=235  cterm=NONE
hi CursorLineNR     ctermfg=250  ctermbg=NONE cterm=NONE
hi VertSplit        ctermfg=235  ctermbg=235  cterm=NONE
hi SignColumn       ctermfg=235  ctermbg=235  cterm=NONE

" Search when cursor is on word
hi IncSearch        ctermfg=NONE ctermbg=NONE cterm=bold

hi Search           ctermfg=10   ctermbg=NONE cterm=NONE
hi NERDTreeFile     ctermfg=245  ctermbg=NONE cterm=NONE

hi NERDTreeFile     ctermfg=245  ctermbg=NONE cterm=NONE
hi NERDTreeExecFile ctermfg=245  ctermbg=NONE cterm=NONE

hi Comment          ctermfg=240  ctermbg=NONE cterm=italic
hi Statement        ctermfg=255  ctermbg=NONE cterm=NONE
hi String           ctermfg=231  ctermbg=NONE cterm=italic
hi Number           ctermfg=255  ctermbg=NONE cterm=NONE

hi TODO             ctermfg=255  ctermbg=NONE cterm=italic
hi Operator         ctermfg=255  ctermbg=NONE cterm=NONE

hi Error            ctermfg=1    ctermbg=NONE cterm=NONE

" Autocomplete menu
hi Pmenu            ctermfg=250 ctermbg=235   cterm=NONE
hi PmenuSel         ctermfg=235 ctermbg=250   cterm=NONE



hi PreProc          ctermfg=245 ctermbg=NONE cterm=NONE

" # Python Specific "
" False None True
" lambda nonlocal pass print return with yield
" class def nextgroup=pythonFunction skipwhite
" as assert break continue del exec global
hi pythonStatement   ctermfg=255 ctermbg=NONE cterm=bold
" elif else if
hi pythonConditional ctermfg=255 ctermbg=NONE cterm=bold
" for while
hi pythonRepeat      ctermfg=255 ctermbg=NONE cterm=bold
" and in is not or
hi pythonOperator    ctermfg=255 ctermbg=NONE cterm=bold
" except finally raise try
hi pythonException   ctermfg=255 ctermbg=NONE cterm=bold
" from import
hi pythonInclude     ctermfg=255 ctermbg=NONE cterm=bold
" async await
hi pythonAsync       ctermfg=255 ctermbg=NONE cterm=bold
" \
hi pythonEscape      ctermfg=255 ctermbg=NONE cterm=bold
" bool str
hi pythonBuiltin     ctermfg=255 ctermbg=NONE cterm=bold
hi pythonFunction    ctermfg=255 ctermbg=NONE cterm=bold

" # Git Commit specific
hi diffAdded         ctermfg=10  ctermbg=NONE cterm=bold
hi diffRemoved       ctermfg=1   ctermbg=NONE cterm=bold

" New ones
hi Title             ctermfg=255 ctermbg=NONE cterm=bold
hi WildMenu          ctermfg=255 ctermbg=NONE cterm=NONE
hi Underlined        ctermfg=255 ctermbg=NONE cterm=underline
hi Directory         ctermfg=255 ctermbg=NONE cterm=underline
hi ErrorMsg          ctermfg=1   ctermbg=NONE cterm=underline
hi mkdCode           ctermfg=255 ctermbg=NONE cterm=italic
hi mkdSnippetSH      ctermfg=255 ctermbg=NONE cterm=italic
" TODO Add lightline colors

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg)
    exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg
    exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('py',  10, 'none')


" Non-color stuff
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


" Ctrl-p specific
hi CtrlPPrtText     ctermfg=10 ctermbg=NONE cterm=NONE
hi CtrlPMatch       ctermfg=10  ctermbg=NONE cterm=NONE

" Input box
hi CtrlPPrtBase ctermfg=2 ctermbg=NONE cterm=italic


hi CtrlPLinePre     ctermfg=2 ctermbg=NONE cterm=italic
hi CtrlPPrtCursor   ctermfg=2  ctermbg=NONE cterm=italic
