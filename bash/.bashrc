# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias usage='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'
alias ls="ls --color"

# Powerline
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
    source /usr/share/powerline/bindings/bash/powerline.sh
fi

alias vim="nvim"
alias nvimdir="cd ~/.config/nvim/"
alias luaconfig="vim ~/.config/awesome/rc.lua"
alias zshconfig="vim ~/.zshrc"
alias zshrefresh="source ~/.zshrc"
alias editorconfig="editor ~/.vimrc"
alias edt="editor"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias pa="php artisan"
alias rs="reset"
alias open="nautilus"
alias html="/var/www/html/"
alias nginx-stop="sudo service nginx stop"
alias nginx-start="sudo service nginx start"
alias apache-stop="sudo service apache2 stop"
alias apache-start="sudo service apache2 start"
alias merge='gco master; g merge develop; gco develop; g push --all'
alias mergef='gco master; g merge dev; gco dev; g push --all'
alias as='./android-studio/bin/studio.sh'
alias fan="sudo pwmconfig"
alias hddtemp="sudo hddtemp /dev/sd*"
alias root-vps="ssh root@172.104.169.95"
alias sheena-vps="ssh sheena-vps@172.104.169.95"
alias zien-vps="ssh zien-vps@172.104.169.95"
alias pz="php zitech"
alias yrw="yarn run watch"
alias yrd="yarn run dev"
alias komuri-dev-server="ssh forge@172.104.39.31"
alias kooc-server="ssh forge@172.104.165.184"
alias new-kooc-server="ssh root@156.67.218.222 -p 22"
alias new-geek-server="ssh geek-new-vps@156.67.218.222"
alias php74="sudo update-alternatives --set php /usr/bin/php7.4"
alias php73="sudo update-alternatives --set php /usr/bin/php7.3"
alias php72="sudo update-alternatives --set php /usr/bin/php7.2"
alias php71="sudo update-alternatives --set php /usr/bin/php7.1"
alias php70="sudo update-alternatives --set php /usr/bin/php7.0"
alias "c=xclip"
alias "v=xclip -o"
alias "cc=xclip -selection clipboard"
alias v="valet"
alias s="start"
alias rst="restart"
alias homesteadconf="vim ~/Homestead/Homestead.yaml"
alias dockremove="sudo apt remove gnome-shell-extension-ubuntu-dock"
alias dockinstall="sudo apt install gnome-shell-extension-ubuntu-dock"
alias lg="lazygit"
alias x="exit"
alias t="tmux"
alias tls="tmux ls"
alias tda="tmux kill-session -a"
alias tr="tmux kill-session -t"
alias alaconf="vim ~/.config/alacritty/alacritty.yml"
alias tmuxconf="vim ~/.tmux.conf"
alias kittyconf="vim ~/.config/kitty/kitty.conf"
alias kittydir="cd ~/.config/kitty"
alias delthemekit="rm -rf ~/.config/kitty/theme.conf"
alias sr="./node_modules/.bin/sequelize"
alias activated-php="sudo chown $USER:$USER /var/run/php/php7.0-fpm.sock"
alias at="alacritty-themes"
alias test_filter="./vendor/phpunit/phpunit/phpunit --filter"
alias testing="./vendor/phpunit/phpunit/phpunit"
alias i3config="vim ~/.config/i3/config"
alias vimdir="cd ~/.config/nvim"
alias perlight="sudo chmod a+rw /sys/class/backlight/intel_backlight/brightness"
export PATH=~/.config/composer/vendor/bin:$PATH
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.yarn/bin


export PATH=~/.config/composer/vendor/bin:$PATH


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
