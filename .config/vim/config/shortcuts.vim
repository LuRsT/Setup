" FKEYS

"Refresh current file
nmap <silent> <F5> :e %<CR>

"Activate NERDTREE
nmap <silent> <F7> :NERDTreeToggle<CR>
let NERDTreeDirArrows = 1

" Tagbar toggle
nnoremap <silent> <F9> :TagbarToggle<CR>

" Get name of vim identifier (for changing colors)
map <F3> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Alt Shortcuts
map <A-t> :Tags<CR>
map <A-f> :Files<CR>
map <A-a> :Ag<CR>
map <A-h> :History<CR>

" nvim Terminal mode
if has("nvim")
  tnoremap <Esc> <C-\><C-n>

  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
endif

" Whacking the space bar you can execute the q macro as many times as you'd like.
noremap <Space> @q

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

" Mark TODO as done
nnoremap X :s/\[\ \]/[X]/<CR>:nohl<CR>

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

" Open/Close folds with space button
nnoremap <space> za
vnoremap <space> zf

" Re-tag
nnoremap T :Start pytags<CR>

" Search using AsyncRun
map <Leader>f :AsyncRun -strip rg --vimgrep --glob '*.py'
