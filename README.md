# My Dotfiles
## Preparation
  * sudo apt-get install -y stow
  * stow 
    ```
    Output
    stow (GNU Stow) version 2.3.1
    ```
## Installation
  * sudo chmod +x makelinks
  * ./makelinks
    ```
    Output
    LINK: alacritty.yml => ../../code/dotfiles/alacritty/alacritty.yml
    LINK: vim-plug => ../../code/dotfiles/nvim/vim-plug
    LINK: UltiSnips => ../../code/dotfiles/nvim/UltiSnips
    LINK: coc-settings.json => ../../code/dotfiles/nvim/coc-settings.json
    LINK: keys => ../../code/dotfiles/nvim/keys
    LINK: modules => ../../code/dotfiles/nvim/modules
    LINK: init.vim => ../../code/dotfiles/nvim/init.vim
    LINK: themes => ../../code/dotfiles/nvim/themes
    LINK: general => ../../code/dotfiles/nvim/general
    LINK: .vimrc => code/dotfiles/vim/.vimrc
    LINK: .zshrc => code/dotfiles/zsh/.zshrc
    LINK: .p10k.zsh => code/dotfiles/p10k/.p10k.zsh
    ```
