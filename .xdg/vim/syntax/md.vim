" Vim universal .md syntax file
" " Language:     Markdown
" " Maintainer:   Jan Andersson <jan.andersson@gmail.com>
" " Last change:  4 Jan 2010
" "
" " Syntax file for John Gruber's Markdown.
" "
if version < 600 "   syntax clear "   elseif exists("b:current_syntax") "     finish "     endif

    syn case ignore

    syn match mdCode      "`[^`]*`"
    syn match mdCode      "\(\t\|    \).*$"
    syn match mdList       "^\s*[-*+]\s\|^\s*\d\+\.\(\s\|$\)"
    syn match mdLine      "^\(\s*[-*_]\)\(\s*[-*_]\)\(\s*[-*_]\)\+$"
    syn match mdHeader     ".\+\n^[=-]\+"
    syn match mdHeader     "^#\+.\+"
    syn match mdLink       "<\(\w\|[@\-&=,?\:\.#\/]\)\+>"
    syn match mdLink
    "!\?\[[^]]\+\](\(\w\|[@\-&=,?\:\.#\/]\)\+\(\s*["'].*["']\)\?)"
    syn match mdLink       "!\?\[[^]]\+\]\s\?\[[^]]*\]"
    syn match mdLink
    "^\s*\[.\+\]\:\s\+\(\w\|[@\-&=,?\:\.#\/]\)\+\s*["'(].*["')]\s*$"
    syn region mdQuote     start="^\s*>\s"        end="^\(\S\)\@!"

    syn case match

    " Define the default highlighting when an item doesn't have highlighting
    yet
    command -nargs=+ HiLink hi def link <args>

    HiLink mdList                Operator
    HiLink mdHeader              Identifier
    HiLink mdQuote               Constant
    HiLink mdLink                String
    HiLink mdCode                Constant
    HiLink mdLine                Constant

    delcommand HiLink

    let b:current_syntax = "md"

