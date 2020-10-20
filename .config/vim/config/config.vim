"BS past autoindents, line boundaries, and even the start of insertion
set backspace=indent,eol,start
set cmdheight=2
set fileencodings=ucs-bom,utf-8,default,latin1
set helplang=en
set history=500
set incsearch
set inccommand=split
set ruler
set shiftwidth=4
set showcmd
set tabstop=4
set termencoding=utf-8
set encoding=utf-8
set updatetime=500
set wildmenu
set number
set smartindent
set cursorline
set scrolloff=5
set gdefault
set nobackup
set directory=.
set noswapfile

set nocompatible
set autoindent
set showmatch
set ignorecase
set smartcase

set expandtab
set shiftround
set mouse=a
set clipboard=unnamedplus

set wildignore+=*/.git/*,*/tmp/*,*.swp

" Folds
set foldmethod=manual

" Save buffer automatically when changing files
set autowrite

" Handle Mac and DOS line-endings but prefer Unix endings
set fileformats=unix,mac,dos

" Set correct syntax to files
au BufNewFile,BufRead *.j2 set filetype=html
au BufNewFile,BufRead *.md set filetype=markdown
autocmd BufRead,BufNewFile *.py let python_highlight_all=1

if has('persistent_undo')
    set undofile
    set undodir=$HOME/.config/vim/undo_files/
endif

" Delete trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e

" Open quickfix window when using quickfix commands like :make
autocmd QuickFixCmdPost [^l]* cwindow
autocmd QuickFixCmdPost l* lwindow

" some common typos
command! QA qa
command! Qa qa
command! Q  q
command! W  w
command! Wq wq
command! WQ wq
command! Vs vs


" make <a-j>, <a-k>, <a-l>, and <a-h> resize windows.
nnoremap <a-j> <c-w>+
nnoremap <a-k> <c-w>-
nnoremap <a-l> <c-w><
nnoremap <a-h> <c-w>>

" make <a-J>, <a-K>, <a-L>, and <a-H> create windows.
nnoremap <a-J> <c-w>s<c-w>k
nnoremap <a-K> <c-w>s
nnoremap <a-H> <c-w>v
nnoremap <a-L> <c-w>v<c-w>h
