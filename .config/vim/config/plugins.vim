" Lighline
set laststatus=2
set ttimeoutlen=1

let g:lightline = {
    \ 'colorscheme': 'gruvbox_material',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ], [ 'filename', 'gitbranch' ] ],
    \   'right': [ [ 'lineinfo'], ['wordcount', 'percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'FugitiveHead',
    \   'filename': 'LightlineFilename',
    \   'wordcount': 'WordCount',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': ':', 'right': '|' },
    \ 'mode_map': {
        \ 'n' : 'N',
        \ 'i' : 'I',
        \ 'R' : 'R',
        \ 'v' : 'V',
        \ 'V' : 'VL',
        \ "\<C-v>": 'VB',
        \ 'c' : 'C',
        \ 's' : 'S',
        \ 'S' : 'SL',
        \ "\<C-s>": 'SB',
        \ 't': 'T',
        \ },
      \ }

function! LightlineModified()
    return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
    return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightlineFilename()
    let fname = expand('%:t')
    return fname == '__Tagbar__' ? g:lightline.fname :
                \ fname =~ '__Gundo\|NERD_tree' ? '' :
                \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
                \ &ft == 'vimshell' ? vimshell#get_status_string() :
                \ ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
                \ ('' != fname ? fname : '[No Name]') .
                \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction


function! WordCount()
    if &filetype ==# 'markdown'
        let currentmode = mode()
        if !exists("g:lastmode_wc")
            let g:lastmode_wc = currentmode
        endif
        " if we modify file, open a new buffer, be in visual ever, or switch modes
        " since last run, we recompute.
        if &modified || !exists("b:wordcount") || currentmode =~? '\c.*v' || currentmode != g:lastmode_wc
            let g:lastmode_wc = currentmode
            let l:old_position = getpos('.')
            let l:old_status = v:statusmsg
            execute "silent normal g\<c-g>"
            if v:statusmsg == "--No lines in buffer--"
                let b:wordcount = 0
            else
                let s:split_wc = split(v:statusmsg)
                if index(s:split_wc, "Selected") < 0
                    let b:wordcount = str2nr(s:split_wc[11])
                else
                    let b:wordcount = str2nr(s:split_wc[5])
                endif
                let v:statusmsg = l:old_status
            endif
            call setpos('.', l:old_position)
            return b:wordcount
        else
            return b:wordcount
        endif
    endif
    return ""
endfunction

" Fzf

" Set up Pop up window
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

""""" Easymotion

" s{char} to move to {char}
map  f <Plug>(easymotion-bd-f)
nmap f <Plug>(easymotion-overwin-f)

" Vim-highlightedyank
let g:highlightedyank_highlight_duration = 200

" Notational fzf vim
let g:nv_search_paths = ['~/vimwiki']

" WhichKey
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
set timeoutlen=500
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
xnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
xnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

" Rust
let g:rustfmt_autosave = 1


" NERD Tree + devicons
let NERDTreeDirArrowExpandable = " "
let NERDTreeDirArrowCollapsible = " "
