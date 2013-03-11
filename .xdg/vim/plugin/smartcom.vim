" Vim global plugin for smarter completion semantics
" Last change:  Sat Apr 19 21:55:26 EST 2008
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_smartcom")
  finish
endif
let loaded_smartcom = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ Interface ]=====================================================

" Remap <TAB> for smart completion on various characters...
inoremap <silent> <TAB>   <c-r>=<SID>Complete()<CR>

" Remap single <S-TAB> for smart completion on padding...
" That is: search the previous line for repeated punctuation and repeat it
inoremap <silent> <S-TAB> <c-r><c-r>=<SID>CompletePadding()<CR>

" Remap double <S-TAB> for smart completion on filepaths...
inoremap <silent> <S-TAB><S-TAB> <c-r>=<SID>CompleteFile()<CR>

" Remap <RIGHT> to have special behaviour when placeholders are pending
inoremap <silent> <RIGHT> <c-r>=<SID>RightKey()<CR>

"=====[ Implementation ]=====================================================

" What placeholders look like and how many are pending...
let s:placeholder_pat = '_\{3,}'
let s:placeholder_count = 0


" Complete the current line by duplicating compatible existing lines...

function! <SID>CompleteLine ()
    " If already completing, keep completing; otherwise, start completing...
    if pumvisible()
        return "\<C-P>"
    else
        return "\<C-X>\<C-L>"
    endif
endfunction


" Do file completion on the current prefix, when appropriate...

function! <SID>CompleteFile ()
    " If already completing, keep completing; otherwise, start completing...
    if pumvisible()
      return "\<C-P>"
    else
        return "\<C-X>\<C-F>"
    endif
endfunction


" Complete with the same padding as the previous line...

let s:PREVPADDING  = '.\{-}\(\A\&\D\&\S\)\1\+'
let s:PREVSPACING  = '.\{-}\(\s\)\1\+'
let s:PREVTEXTLINE = '\S.*\n\_.*\%#'

function! <SID>CompletePadding ()
    " Grab the necessary context...
    let col = col('.')-1                " ...strings are zero-based
    let prev_line_num = search(s:PREVTEXTLINE,'bnW')
    let prev_line = getline(prev_line_num ? prev_line_num : line('.')-1)

    " Work out what the previous line's padding is....
    let padding = matchlist(prev_line, s:PREVPADDING, col)

    " If no padding, then use spaces...
    if empty(padding)
        let padding = matchlist(prev_line, s:PREVSPACING, col)
    endif

    "If still no padding, give up...
    if empty(padding)
        return ""
    endif

    " Otherwise, return the appropriate amount of padding...
    return repeat(padding[1], strlen(padding[0]))

endfunction


" Completions table:
"   col 1 is left context,
"   col 2 is right context,
"   col 3 is what to insert
"   col 4 is whether to restore the cursor position
"   col 5 is an optional filetype to constrain where completion valid
"   col 6 is an optional "filename pattern" to constrain where completion valid
"   col 7 is how many placeholders the replacement text has
let s:completions = []

" Public function to add other completions (which are tried first)
function! SmartcomAdd (left, right, completion, ...)
    " Any options???
    let opts = empty(a:000) ? {} : a:000[0]

    " Extract them...
    let restore_cursor = get(opts, 'restore',  0)
    let filetype       = get(opts, 'filetype', "")
    let filepat        = get(opts, 'filepat',  "")
    let placeholders   = get(opts, 'verbatim', 0) ? 0 : len(split(a:completion, s:placeholder_pat, 1))-1

    " Remember everything...
    call insert(s:completions, [a:left, a:right, a:completion, restore_cursor, filetype, filepat, placeholders])
endfunction

" Completion action table:
"   col 1 is left context,
"   col 2 is right context,
"   col 3 is what to do
let s:completion_actions = []

" Public function to add completion actions (which are executed first)
function! SmartcomAddAction (left, right, action)
    call insert(s:completion_actions, [a:left, a:right, a:action])
endfunction


let s:NIL = ""
let s:RESTORE = {'restore':1}

"                  Left   Right   Complete with...         Autorestore
"                  ====   =====   ====================     ==========
call SmartcomAdd(  '{',   s:NIL,  "}"                    , s:RESTORE   )
call SmartcomAdd(  '{',   '}',    "\<CR>\<C-D>\<UP>\<RIGHT>\<CR>"      )
call SmartcomAdd(  '\[',  s:NIL,  "]"                    , s:RESTORE   )
call SmartcomAdd(  '\[',  '\]',    "\<CR>\<ESC>O\<TAB>"                )
call SmartcomAdd(  '(',   s:NIL,  ")"                    , s:RESTORE   )
call SmartcomAdd(  '(',   ')',    "\<CR>\<ESC>O\<TAB>"                 )
call SmartcomAdd(  '<',   s:NIL,   ">"                   , s:RESTORE   )
call SmartcomAdd(  '<',   '>',    "\<CR>\<ESC>O\<TAB>"                 )
call SmartcomAdd(  '"',   s:NIL,  '"'                    , s:RESTORE   )
call SmartcomAdd(  '"',   '"',    "\\n"                  , s:RESTORE   )
call SmartcomAdd(  "'",   s:NIL,  "'"                    , s:RESTORE   )
call SmartcomAdd(  "'",   "'",    s:NIL,                               )


let s:reset_complete_opt = {}

" Implement completion magic...
let s:tab = "\<TAB>"
function! <SID>Complete ()

    " Restore standard 'complete' option if necessary...
    let bufnum = bufnr('%')
    if has_key(s:reset_complete_opt, bufnum)
        let &l:complete = s:reset_complete_opt[bufnum]
        unlet s:reset_complete_opt[bufnum]
    endif

    " Tab as usual at the left margin...
    let cursorpos = getpos('.')
    let col = cursorpos[2]
    if col == 1
        return s:tab
    endif

    " How to restore the cursor position...
    let reversion = "\<C-O>:call setpos('.'," . string(cursorpos) . ")\<CR>"

    " Determine context of completion...
    let curr_line = getline('.')
    let curr_pos  = '\%' . col . 'c'

    " If a matching smart completion action has been specified, do it first...
    let old_complete_opt = &complete
    for [left, right, action] in s:completion_actions
        let pattern = left . curr_pos . right
        if curr_line =~ pattern
            execute action
        endif
    endfor
    if old_complete_opt != &complete
        let s:reset_complete_opt[bufnum] = old_complete_opt
    endif

    " If already in a completion pop-up selector, select the next alternative...
    if pumvisible()
        return "\<C-N>"
    endif

    " If a matching smart completion has been specified, use that...
    let filename = expand('%')
    for [left, right, completion, restore_cursor, filetype, filepat, placeholders] in s:completions
        " Only try completions for which the filetype and/or filename match...
        if strlen(filetype) && &filetype != filetype
            continue
        elseif strlen(filepat) && filename !~ filepat
            continue
        endif

        " Build the pattern to be tested...
        let pattern = left . curr_pos . right
        if curr_line =~ pattern
            " Code around bug in setpos() when used at EOL...
            if col == strlen(curr_line)+1 && strlen(completion)==1 
                let reversion = "\<LEFT>"
            endif

            " Remember the extra placeholders...
            if placeholders
                " Placeholder count incremented by N-1 because we immediately jump to the first...
                let s:placeholder_count += placeholders - 1

                " Have to jump from the start of the inserted text...
                let restore_cursor = 1

                " This is how to jump to the first placeholder...
                let reversion .= "\<ESC>/" . s:placeholder_pat . "\<CR>cw"
            endif

            " Return the completion...
            return completion . (restore_cursor ? reversion : "")
        endif
    endfor

    " Otherwise, if not after an identifier, no completion; just a tab...
    if curr_line !~ '\k' . curr_pos
        return s:tab

    " Otherwise, autocomplete with next alternative
    else
        return "\<C-N>"

    endif
endfunction


" Give <RIGHT> key special behaviour when placeholders are pending...

function! <SID>RightKey ()
    if s:placeholder_count
        let s:placeholder_count -= 1
        if getline('.') !~ '\S'
            delete
        endif
        return "\<ESC>/" . s:placeholder_pat . "\<CR>cw"
    else
        return "\<RIGHT>"
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
