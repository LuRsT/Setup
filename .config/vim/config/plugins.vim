" NERDTree
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowHidden = 1

" Lighline
set laststatus=2
set ttimeoutlen=1

let g:lightline = {
    \ 'colorscheme': 'gruvbox_material',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ], [ 'filename', 'gitbranch' ] ],
    \   'right': [ [ 'lineinfo'], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'FugitiveHead',
    \   'filename': 'LightlineFilename',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': ':', 'right': '|' }
    \ }

" Short names for vim modes
let g:lightline = {
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

" Vim-Markdown
let g:vim_markdown_folding_disabled = 1

" Deoplete
let g:deoplete#enable_at_startup = 1

" Ale
let b:ale_linters = ['flake8', 'pylint']
let b:ale_fixers = ['black']
let g:ale_set_highlights = 0
let g:ale_sign_error = '>'
let g:ale_sign_warning = '-'
let g:ale_virtualtext_cursor = 1

" Ags
nnoremap <leader>a :Ags

" Fzf

" Set up Pop up window
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

""""" Easymotion

" s{char} to move to {char}
map  s <Plug>(easymotion-bd-f)
nmap s <Plug>(easymotion-overwin-f)

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
