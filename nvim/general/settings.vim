" set leader key
let g:mapleader = "\<Space>"
set fileencodings=utf-8
set ttyfast

set nocompatible
" set guicursor=
syntax enable                           " Enables syntax highlighing
set noswapfile
set backspace=indent,eol,start
set nowrap                              " Display long lines as just one line
set encoding=utf-8                      " The encoding displayed
set pumheight=10                        " Makes popup menu smaller
set fileencoding=utf-8                  " The encoding written to file
set ruler              			            " Show the cursor position all the time
set iskeyword+=-                      	" treat dash separated words as a word text object"
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set t_Co=256                            " Support 256 colors
set conceallevel=0                      " So that I can see `` in markdown files
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set laststatus=0                        " Always display the status line
set number                              " Line numbers
set relativenumber
set noshowmode                          " We don't need to see things like -- INSERT -- anymore
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set updatetime=300                      " Faster completion
set timeoutlen=500
set formatoptions-=cro                  " Stop newline continution of comments
set wildmenu
set path+=**
set colorcolumn=120

highlight ColorSchme guibg=dark
" au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
" autocmd BufWinLeave *.* mkview
" autocmd BufWinEnter *.* silent loadview
" augroup tab
"     autocmd!
"     autocmd BufReadPost * tabedit %
" augroup END

" You can't stop me
cmap w!! w !sudo tee %

set lazyredraw            " improve scrolling performance when navigating through large results

" Disable arrow key in vim, see https://goo.gl/s1yfh4.
nnoremap <Up> <nop>
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
inoremap <Up> <nop>
inoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Right> <nop>
