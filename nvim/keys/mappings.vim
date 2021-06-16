" mearch file
" Better nav for omnicomplete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" Use alt + hjkl to resize windows
nnoremap <M-j>    :resize -2<CR>
nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" I hate escape more than anything else
inoremap jk <Esc>
inoremap kj <Esc>
imap jj <Esc>
inoremap jl <Esc>

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" " TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" map <C-PageUp> :bp<CR>
" map <C-PageDown> :bn<CR>

" Use control-c instead of escape
nnoremap <C-c> <Esc>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

nnoremap <silent> <leader><space> :noh<cr>

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>

nnoremap <space>/ :Commentary<CR>
vnoremap <space>/ :Commentary<CR>

" terminal
nnoremap <leader>` :!tmux split-window -v -p 20 <CR> <CR>
nnoremap <C-`> :botright 15 sp term://zsh <CR>

" enable ncm2 for all buffers
" autocmd BufEnter * call ncm2#enable_for_buffer()
" set completeopt=noinsert,menuone,noselect


" vim-javascript
let g:javascript_plugin_jsdoc = 1

" test javascript
autocmd FileType javascript map <buffer> <F10> :exec '!yarn run test'<CR>


"tagbar
nmap <F8> :TagbarToggle<CR>

nmap <C-g> :!ctags -R --PHP-kinds=+cf <CR>

command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'
map <c-s> <esc>:w<cr>:Silent php-cs-fixer fix %:p<cr>


" nnoremap <c-z> <nop>
