if &cp | set nocp | endif
let s:cpo_save=&cpo
set termguicolors

set runtimepath=$HOME/.config/vim,$VIM,$VIMRUNTIME

filetype plugin indent on

let &cpo=s:cpo_save
unlet s:cpo_save

"BS past autoindents, line boundaries, and even the start of insertion
set backspace=indent,eol,start
set cmdheight=2
set incsearch
set inccommand=split
set ruler
set shiftwidth=4
set tabstop=4
set encoding=utf-8
set updatetime=500
set wildmenu
set number
set cursorline
set scrolloff=5
set gdefault
set nobackup
set noswapfile

set autoindent
set showmatch
set ignorecase
set smartcase

set expandtab
set shiftround
set mouse=a
set clipboard=unnamedplus

set wildignore+=*/.git/*,*/tmp/*,*.swp

" Save buffer automatically when changing files
set autowrite

" Handle Mac and DOS line-endings but prefer Unix endings
set fileformats=unix,mac,dos

" Delete trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e
