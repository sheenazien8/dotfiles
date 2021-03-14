set runtimepath^=~/.vim runtimepath+=~/.vim/after
" let &packpath = &runtimepath
" source ~/.vimrc
source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/keys/mappings.vim
source $HOME/.config/nvim/modules/tagbar.vim
source $HOME/.config/nvim/themes/gruvbox.vim
source $HOME/.config/nvim/modules/lightline.vim
source $HOME/.config/nvim/modules/ale.vim
source $HOME/.config/nvim/modules/dog-generate.vim
source $HOME/.config/nvim/modules/php-doc.vim
source $HOME/.config/nvim/modules/phpactor.vim
source $HOME/.config/nvim/modules/coc.vim
source $HOME/.config/nvim/modules/fzf.vim
source $HOME/.config/nvim/modules/jsx-improve.vim

let g:php_refactor_command='php /usr/local/bin/refactor.phar'
