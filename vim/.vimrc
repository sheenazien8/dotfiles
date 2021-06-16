" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin()
Plug 'joshdick/onedark.vim' 
Plug 'morhetz/gruvbox'
Plug 'jiangmiao/auto-pairs'
call plug#end()

" set leader key
let g:mapleader = "\<Space>"
set fileencodings=utf-8
set ttyfast
set nocompatible
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
set background=dark                     " tell vim what the background color looks like
set showtabline=2                       " Always show tabs
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set updatetime=300                      " Faster completion
set timeoutlen=500                      " By default timeoutlen is 1000 ms
set formatoptions-=cro                  " Stop newline continution of comments
set wildmenu
" Don't offer to open certain files/directories
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
set wildignore+=*.pdf,*.psd
set wildignore+=node_modules/*,bower_components/*,vendor/*
set path+=**
set colorcolumn=120
set showcmd
set cursorline

" highlight ColorSchme guibg=dark
au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC

" onedark.vim override: Don't set a background color when running in a terminal;
if (has("autocmd") && !has("gui_running"))
  augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
  augroup END
endif

"hi Comment cterm=italic
let g:onedark_hide_endofbuffer=1
let g:onedark_termcolors=256

hi Comment cterm=italic

syntax enable
" let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection= '0'
colorscheme onedark
let g:php_var_selector_is_identifier = 1
let php_sql_query=1
if (has("termguicolors"))
    hi LineNr ctermbg=NONE guibg=NONE
endif

