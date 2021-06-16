set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
" source ~/.vimrc
source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/keys/mappings.vim
source $HOME/.config/nvim/modules/tagbar.vim
source $HOME/.config/nvim/themes/onedark.vim
source $HOME/.config/nvim/modules/statusline.vim
source $HOME/.config/nvim/modules/dog-generate.vim
source $HOME/.config/nvim/modules/php-doc.vim
source $HOME/.config/nvim/modules/phpactor.vim
source $HOME/.config/nvim/modules/vimwiki.vim
source $HOME/.config/nvim/modules/calendar.vim
source $HOME/.config/nvim/modules/coc.vim
source $HOME/.config/nvim/modules/nerdrw.vim
source $HOME/.config/nvim/modules/fzf.vim
source $HOME/.config/nvim/modules/jsx-improve.vim
source $HOME/.config/nvim/modules/tmux-navigator.vim
source $HOME/.config/nvim/modules/dart.vim
source $HOME/.config/nvim/modules/session.vim

au BufNewFile,BufRead *.py
      \ set expandtab       |" replace tabs with spaces
      \ set autoindent      |" copy indent when starting a new line
      \ set tabstop=4
      \ set softtabstop=4
      \ set shiftwidth=4

" au BufNewFile,BufRead *.php
"       \ set foldmethod=indent

nnoremap <space> za
" vnoremap <leader>e :call PHPExtractVariable()<cr>

function! PHPExtractVariable()
    let l:name = input("Name of new variable: $")
    normal! gvx
    execute "normal! i$".l:name
    execute "normal! O$".l:name." = "
    normal! pa;
endfunction
