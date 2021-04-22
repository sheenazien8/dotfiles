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
Plug 'easymotion/vim-easymotion'
Plug 'vimwiki/vimwiki'
Plug 'mattn/calendar-vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'jiangmiao/auto-pairs'
Plug 'editorconfig/editorconfig-vim'
Plug 'preservim/tagbar'
Plug 'christoomey/vim-tmux-navigator'
Plug 'preservim/vimux'
" Plug 'tobyS/vmustache'

" Marketplace intelisense
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neovim/nvim-lspconfig'

" ColorSchme
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'ayu-theme/ayu-vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'arcticicestudio/nord-vim'

" Global Language

" PHP
Plug 'tobyS/pdv'
Plug 'noahfrederick/vim-composer'
Plug 'noahfrederick/vim-laravel'
Plug 'phpactor/phpactor', {'for': 'php', 'branch': 'master', 'do': ':call phpactor#Update()'}
Plug 'c9s/phpunit.vim'
Plug 'jwalton512/vim-blade'
Plug 'StanAngeloff/php.vim'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'heavenshell/vim-jsdoc', {
  \ 'for': ['javascript', 'javascript.jsx','typescript'],
  \ 'do': 'make install'
\}
Plug 'posva/vim-vue'
Plug 'epilande/vim-react-snippets'

" HTML
Plug 'mattn/emmet-vim'

call plug#end()
