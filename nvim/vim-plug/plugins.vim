" auto-install vim-plug
"if empty(glob('~/.config/nvim/autoload/plug.vim'))
"  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
"    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"endif
"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')
if has('win32')&&!has('win64')
  let curl_exists=expand('C:\Windows\Sysnative\curl.exe')
else
  let curl_exists=expand('curl')
endif

if !filereadable(vimplug_exists)
  if !executable(curl_exists)
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!"curl_exists" -fLo " . shellescape(vimplug_exists) . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif


call plug#begin('~/.config/nvim/autoload/plugged')
" System
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'yegappan/mru'
" Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'jiangmiao/auto-pairs'
Plug 'editorconfig/editorconfig-vim'
Plug 'vimwiki/vimwiki'
Plug 'preservim/tagbar'

" Marketplace intelisense
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ColorSchme
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'ayu-theme/ayu-vim'

" PHP
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
" Plug 'ncm2/ncm2'
" Plug 'phpactor/ncm2-phpactor'
" Plug 'roxma/nvim-yarp'
" Plug 'ncm2/ncm2-path'
" Plug 'phpactor/phpactor', {'for': 'php', 'branch': 'master', 'do': 'composer install --no-dev -o'}

" Plug 'arnaud-lb/vim-php-namespace'
Plug 'jwalton512/vim-blade'
Plug 'StanAngeloff/php.vim'

" Laravel
Plug 'noahfrederick/vim-composer'     "|
Plug 'noahfrederick/vim-laravel'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'heavenshell/vim-jsdoc', {
  \ 'for': ['javascript', 'javascript.jsx','typescript'],
  \ 'do': 'make install'
\}
Plug 'posva/vim-vue'

" HTML
Plug 'mattn/emmet-vim'

call plug#end()
