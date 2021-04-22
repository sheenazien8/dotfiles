" set leader key
let g:mapleader = "\<Space>"
set fileencodings=utf-8
set ttyfast

set nocompatible
" set guicursor=
syntax enable                           " Enables syntax highlighing
set noswapfile
set hidden                              " Required to keep multiple buffers open multiple buffers
set backspace=indent,eol,start
set softtabstop=0
set expandtab
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
set tabstop=2                           " Insert 2 spaces for a tab
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smarttab                            " Makes tabbing smarter will realize you have 2 vs 4
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set laststatus=0                        " Always display the status line
set number                              " Line numbers
set relativenumber
set showtabline=2                       " Always show tabs
set noshowmode                          " We don't need to see things like -- INSERT -- anymore
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set updatetime=300                      " Faster completion
" Time in milliseconds to wait for a mapped sequence to complete,
" see https://goo.gl/vHvyu8 for more info
set timeoutlen=500
set formatoptions-=cro                  " Stop newline continution of comments
set wildmenu
set path+=**
set colorcolumn=120
" set nohlsearch
" set cursorline

set title
set titlestring=
set titlestring+=%(%{hostname()}\ \ %)
set titlestring+=%(%{expand('%:p')}\ \ %)
set titlestring+=%{strftime('%Y-%m-%d\ %H:%M',getftime(expand('%')))}

" set viewdir="./../modules/view/"

" set scrolloff=8

highlight ColorSchme guibg=dark
au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
" autocmd BufWinLeave *.* mkview
" autocmd BufWinEnter *.* silent loadview
" augroup tab
"     autocmd!
"     autocmd BufReadPost * tabedit %
" augroup END
" You can't stop me
cmap w!! w !sudo tee %

set lazyredraw            " improve scrolling performance when navigating through large results

" exe "hi! StatusLineNC"   .s:fmt_none   .s:fg_red .s:bg_base02 .s:fmt_revbb
" exe "hi! VertSplit"  .s:fmt_none   .s:fg_red .s:bg_red
" Disable arrow key in vim, see https://goo.gl/s1yfh4.
" nnoremap <Up> <nop>
" nnoremap <Down> <nop>
" nnoremap <Left> <nop>
" nnoremap <Right> <nop>
" inoremap <Up> <nop>
" inoremap <Down> <nop>
" inoremap <Left> <nop>
" inoremap <Right> <nop>
