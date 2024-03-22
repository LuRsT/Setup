" Get name of vim identifier (for changing colors)
map <F3> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Use tab and shift tab to indent region
nmap <tab> v>
nmap <s-tab> v<
vmap <tab> >gv
vmap <s-tab> <gv

" Better file-navigation with Enter and Backspace
nnoremap <BS> {
onoremap <BS> {
vnoremap <BS> {
nnoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
onoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vnoremap <CR> }

map <ESC>[8~    <End>
map <ESC>[7~    <Home>

""" Control keys

" Easier Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Display filename
nnoremap <C-x> :echo @%<CR>

" Use ; as ;
nnoremap ; :

" Remove Q because who needs ex mode?
nnoremap Q <nop>

" Search for files
nnoremap <C-p> :Files<CR>
nnoremap <C-g> :Buffers<CR>

" """""" LEADER KEYS

" Ags
nnoremap <Leader>a :Ags<Space>
nnoremap <Leader>aa :Ags<Space><C-R>=expand('<cword>')<CR><CR>
nnoremap <Leader>* :Ags<CR><Space>

" Mark a todo item with an x [X]
map <leader>tx :s/\[\ \]/[X]/<CR>:nohl<CR>

" Open .vim config stuff
map <leader>vv :e ~/.config/vimrc<CR>
map <leader>vs :e ~/.config/vim/config/shortcuts.vim<CR>
map <leader>vp :e ~/.config/vim/config/plugins.vim<CR>
map <leader>vc :e ~/.config/vim/config/config.vim<CR>


" Fzf stuff
map <leader>zb :Buffers<CR>
map <leader>zbc :BCommits<CR>
map <leader>zc :Commits<CR>
map <leader>zf :Files<CR>
map <leader>zh :History<CR>
map <leader>zm :Marks<CR>
map <leader>zs :Rg<CR>
map <leader>. :Files<CR>
map <leader><Space> :Files<CR>
map <leader>zt :Tags<CR>
map <leader>f :Files<CR>

map <leader>ft :NERDTreeToggle<CR>

" VimPlug
map <leader>pu :PlugUpdate<CR>
map <leader>pc :PlugClean<CR>

" Notational
map <leader>n :NV<CR>

" Searching
map <leader>s :Rg<CR>

" Execute a command from the current line and past results below
nmap <leader>E yyp:.!bash<CR>

" Windows
nmap <leader>wv :vs<CR>
nmap <leader>ws :sp<CR>

nmap <leader>wh <C-W><C-H>
nmap <leader>wl <C-W><C-L>
nmap <leader>wj <C-W><C-J>
nmap <leader>wk <C-W><C-K>

" Open dir drawer
nmap <leader>op :NERDTreeToggle<CR>

" Abreviations

:iabbrev <buffer> for@ for _ in x:
