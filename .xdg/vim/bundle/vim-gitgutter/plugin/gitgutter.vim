if exists('g:loaded_gitgutter') || !executable('git') || !has('signs') || &cp
  finish
endif
let g:loaded_gitgutter = 1

" Initialisation {{{

function! s:set(var, default)
  if !exists(a:var)
    if type(a:default)
      exe 'let' a:var '=' string(a:default)
    else
      exe 'let' a:var '=' a:default
    endif
  endif
endfunction

call s:set('g:gitgutter_enabled',               1)
call s:set('g:gitgutter_signs',                 1)
call s:set('g:gitgutter_highlight_lines',       0)
" let s:highlight_lines = g:gitgutter_highlight_lines
call s:set('g:gitgutter_sign_column_always',    0)
call s:set('g:gitgutter_realtime',              1)
call s:set('g:gitgutter_eager',                 1)
call s:set('g:gitgutter_sign_added',            '+')
call s:set('g:gitgutter_sign_modified',         '~')
call s:set('g:gitgutter_sign_removed',          '_')
call s:set('g:gitgutter_sign_modified_removed', '~_')
call s:set('g:gitgutter_diff_args',             '')
call s:set('g:gitgutter_escape_grep',           0)

function! s:init()
  if !exists('g:gitgutter_initialised')
    call highlight#define_sign_column_highlight()
    call highlight#define_highlights()
    call highlight#define_signs()
    let g:gitgutter_initialised = 1
  endif
endfunction

" }}}


" Public interface {{{

function! GitGutterAll()
  for buffer_id in tabpagebuflist() 
    call GitGutter(expand('#' . buffer_id . ':p'))
  endfor
endfunction
command GitGutterAll call GitGutterAll()

" Supply optional argument to use realtime mode.
function! GitGutter(file, ...)
  call utility#set_file(a:file)
  if utility#is_active()
    call s:init()
    if (a:0 == 1) || utility#has_unsaved_changes(a:file)
      let diff = diff#run_diff(1)
    else
      let diff = diff#run_diff(0)
    endif
    let s:hunks = diff#parse_diff(diff)
    let modified_lines = diff#process_hunks(s:hunks)
    if g:gitgutter_sign_column_always
      call sign#add_dummy_sign()
    else
      if utility#differences(s:hunks)
        call sign#add_dummy_sign()  " prevent flicker
      else
        call sign#remove_dummy_sign()
      endif
    endif
    call sign#clear_signs(a:file)
    call sign#find_other_signs(a:file)
    call sign#show_signs(a:file, modified_lines)
  else
    call hunk#reset()
  endif
endfunction
command GitGutter call GitGutter(utility#current_file())

function! GitGutterDisable()
  let g:gitgutter_enabled = 0
  call sign#clear_signs(utility#file())
  call sign#remove_dummy_sign()
  call hunk#reset()
endfunction
command GitGutterDisable call GitGutterDisable()

function! GitGutterEnable()
  let g:gitgutter_enabled = 1
  call GitGutter(utility#current_file())
endfunction
command GitGutterEnable call GitGutterEnable()

function! GitGutterToggle()
  if g:gitgutter_enabled
    call GitGutterDisable()
  else
    call GitGutterEnable()
  endif
endfunction
command GitGutterToggle call GitGutterToggle()

function! GitGutterLineHighlightsDisable()
  let g:gitgutter_highlight_lines = 0
  call highlight#define_sign_line_highlights()
endfunction
command GitGutterLineHighlightsDisable call GitGutterLineHighlightsDisable()

function! GitGutterLineHighlightsEnable()
  let g:gitgutter_highlight_lines = 1
  call highlight#define_sign_line_highlights()
endfunction
command GitGutterLineHighlightsEnable call GitGutterLineHighlightsEnable()

function! GitGutterLineHighlightsToggle()
  let g:gitgutter_highlight_lines = (g:gitgutter_highlight_lines ? 0 : 1)
  call highlight#define_sign_line_highlights()
endfunction
command GitGutterLineHighlightsToggle call GitGutterLineHighlightsToggle()

function! GitGutterNextHunk(count)
  if utility#is_active()
    let current_line = line('.')
    let hunk_count = 0
    for hunk in s:hunks
      if hunk[2] > current_line
        let hunk_count += 1
        if hunk_count == a:count
          execute 'normal!' hunk[2] . 'G'
          break
        endif
      endif
    endfor
  endif
endfunction
command -count=1 GitGutterNextHunk call GitGutterNextHunk(<count>)

function! GitGutterPrevHunk(count)
  if utility#is_active()
    let current_line = line('.')
    let hunk_count = 0
    for hunk in reverse(copy(s:hunks))
      if hunk[2] < current_line
        let hunk_count += 1
        if hunk_count == a:count
          execute 'normal!' hunk[2] . 'G'
          break
        endif
      endif
    endfor
  endif
endfunction
command -count=1 GitGutterPrevHunk call GitGutterPrevHunk(<count>)

" Returns the git-diff hunks for the file or an empty list if there
" aren't any hunks.
"
" The return value is a list of lists.  There is one inner list per hunk.
"
"   [
"     [from_line, from_count, to_line, to_count],
"     [from_line, from_count, to_line, to_count],
"     ...
"   ]
"
" where:
"
" `from`  - refers to the staged file
" `to`    - refers to the working tree's file
" `line`  - refers to the line number where the change starts
" `count` - refers to the number of lines the change covers
function! GitGutterGetHunks()
  return utility#is_active() ? s:hunks : []
endfunction

" Returns an array that contains a summary of the current hunk status.
" The format is [ added, modified, removed ], where each value represents
" the number of lines added/modified/removed respectively.
function! GitGutterGetHunkSummary()
  return hunk#summary()
endfunction

nnoremap <silent> <Plug>GitGutterNextHunk :<C-U>execute v:count1 . "GitGutterNextHunk"<CR>
nnoremap <silent> <Plug>GitGutterPrevHunk :<C-U>execute v:count1 . "GitGutterPrevHunk"<CR>

if !hasmapto('<Plug>GitGutterNextHunk') && maparg(']h', 'n') ==# ''
  nmap ]h <Plug>GitGutterNextHunk
  nmap [h <Plug>GitGutterPrevHunk
endif

augroup gitgutter
  autocmd!

  if g:gitgutter_realtime
    autocmd CursorHold,CursorHoldI * call GitGutter(utility#current_file(), 1)
  endif

  if g:gitgutter_eager
    autocmd BufEnter,BufWritePost,FileWritePost,FileChangedShellPost * call GitGutter(utility#current_file())
    autocmd TabEnter * call GitGutterAll()
    if !has('gui_win32')
      autocmd FocusGained * call GitGutterAll()
    endif
  else
    autocmd BufReadPost,BufWritePost,FileReadPost,FileWritePost,FileChangedShellPost * call GitGutter(utility#current_file())
  endif
  autocmd ColorScheme * call highlight#define_sign_column_highlight() | call highlight#define_highlights()
augroup END

" }}}

" vim:set et sw=2 fdm=marker:
