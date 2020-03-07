" FKEYS

"Activate NERDTREE
nmap <silent> <F7> :NERDTreeToggle<CR>
let NERDTreeDirArrows = 1

" Get name of vim identifier (for changing colors)
map <F3> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Alt Shortcuts
map <A-t> :Tags<CR>
map <A-f> :Files<CR>
map <A-a> :Ag<CR>
map <A-h> :History<CR>

" nvim Terminal mode
if has("nvim")
  au TermOpen * tnoremap <Esc> <c-\><c-n>
  au FileType fzf tunmap <Esc>

  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
endif

" some common typos
command! QA qa
command! Qa qa
command! Q  q
command! W  w
command! Wq wq
command! WQ wq
command! Vs vs

" Easier Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Display filename in statusbar
nnoremap <C-x> :set statusline=%f<CR>

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


" Search
nmap gr :vimgrep '' **/* \| copen 20<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>

" LEADER KEYS

" Mark a todo item with an x [X]
map <leader>tx :s/\[\ \]/[X]/<CR>:nohl<CR>

" Open .vim config stuff
map <leader>v :e ~/.config/vimrc<CR>
map <leader>vs :e ~/.config/vim/config/shortcuts.vim<CR>

map <leader>sf :Files<CR>
map <leader>ss :Rg<CR>
map <leader>st :Tags<CR>
map <leader>sh :History<CR>

map <leader>ft :NERDTreeToggle<CR>


" Execute a command from the current line and past results below
nmap <leader>E yyp:.!bash<CR>
