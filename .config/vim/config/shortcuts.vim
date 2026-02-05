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

" Display filename
nnoremap <C-x> :echo @%<CR>

" Use ; as ;
nnoremap ; :

" Remove Q because who needs ex mode?
nnoremap Q <nop>

" Search for files
nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-g> :Telescope buffers<CR>

" """""" LEADER KEYS

" Mark a todo item with an x [X]
map <leader>tx :s/\[\ \]/[X]/<CR>:nohl<CR>

" Open .vim config stuff
map <leader>vv :e ~/.config/vimrc<CR>
map <leader>vs :e ~/.config/vim/config/shortcuts.vim<CR>
map <leader>vp :e ~/.config/vim/config/plugins.vim<CR>
map <leader>vc :e ~/.config/vim/config/config.vim<CR>

map <leader>ft :Neotree<CR>

" Execute a command from the current line and past results below
nmap <leader>E yyp:.!bash<CR>

" Windows
nmap <leader>wv :vs<CR>
nmap <leader>ws :sp<CR>

nmap <leader>wh <C-W><C-H>
nmap <leader>wl <C-W><C-L>
nmap <leader>wj <C-W><C-J>
nmap <leader>wk <C-W><C-K>


" Abreviations
:iabbrev for@ for _ in x:
