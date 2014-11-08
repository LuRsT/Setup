set t_Co=256

set laststatus=2
set nonumber
colorscheme desert

setlocal textwidth=80
setlocal wrapmargin=0

set foldcolumn=10
set columns=100

nnoremap <Space> zt


" Source:
" http://stackoverflow.com/questions/114431/fast-word-count-function-in-vim
let g:word_count="<unknown>"
fun! WordCount()
    return g:word_count
endfun
fun! UpdateWordCount()
    let s = system("wc -w ".expand("%p"))
    let parts = split(s, ' ')
    if len(parts) > 1
        let g:word_count = parts[0]
    endif
endfun

augroup WordCounter
    au! CursorHold * call UpdateWordCount()
    au! CursorHoldI * call UpdateWordCount()
augroup END

" how eager are you? (default is 4000 ms)
set updatetime=500

" modify as you please...
set statusline=%{WordCount()}\ words
