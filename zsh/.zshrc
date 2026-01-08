export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="fwalch"

plugins=(git z composer laravel wakatime fzf-tab fzf)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

function homestead() {
    ( cd ~/Homestead && vagrant $* )
}
function ubuntu() {
    ( cd ~/ubuntu16 && vagrant $* )
}
composer-link() {
    composer config repositories.local '{"type": "path", "url": "'$1'"}' --file composer.json
}

function switch-php() {
    valet stop; sudo update-alternatives --set php /usr/bin/php$1; rm -f ~/.valet/valet.sock; valet install; valet use $1;
}

httpgrep() {
  local selected key cmd

  selected=$(history 1 \
    | tail -r \
    | grep -E 'http .*((http(s)?://)|(:[0-9]+/))' \
    | awk '{$1=""; sub(/^ +/, ""); print}' \
    | fzf --ansi --no-sort --height=40% --reverse --prompt="http> " \
          --expect=enter,ctrl-r)

  key=$(head -n1 <<< "$selected")    # which key pressed
  cmd=$(tail -n+2 <<< "$selected")   # actual command

  if [[ -z "$cmd" ]]; then
    return
  fi

  echo "🔎 Selected command:"
  echo "$cmd"
  echo "key pressed: $key"

  if [[ "$key" == "enter" ]]; then
    # Copy to clipboard
    echo -n "$cmd" | pbcopy
    echo "✅ Copied to clipboard"
  elif [[ "$key" == "ctrl-r" ]]; then
    # Run the command
    echo "⚡ Running:"
    eval "$cmd"
  fi
}

# Register widget
zle -N httpgrep

# Bind Ctrl+G
bindkey '^G' httpgrep


# alias l='lsd -l'
# alias la='lsd -a'
# alias ls='lsd'
# alias ll='lsd'
# alias lla='lsd -la'
# alias lt='lsd --tree'
alias vi="editor"
alias vim="nvim"
alias vimconfig="vi ~/.vimrc"
alias nvimdir="cd ~/.config/nvim/"
alias luaconfig="vim ~/.config/awesome/rc.lua"
alias zshconfig="vim ~/.zshrc"
alias zshrefresh="source ~/.zshrc"
alias editorconfig="editor ~/.vimrc"
alias edt="editor"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias pa="php artisan"
alias rs="reset"
alias cl="clear"
# alias open="nautilus"
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
alias yrs="yarn run start"
alias komuri-dev-server="ssh forge@172.104.39.31"
alias kooc-server="ssh forge@172.104.165.184"
alias new-kooc-server="ssh root@156.67.218.222 -p 22"
alias new-geek-server="ssh geek-new-vps@156.67.218.222"
alias php74="sudo update-alternatives --set php /usr/bin/php7.4"
alias php73="sudo update-alternatives --set php /usr/bin/php7.3"
alias php72="sudo update-alternatives --set php /usr/bin/php7.2"
alias php71="sudo update-alternatives --set php /usr/bin/php7.1"
alias php70="sudo update-alternatives --set php /usr/bin/php7.0"
alias php56="sudo update-alternatives --set php /usr/bin/php5.6"
alias v="valet"
alias s="start"
alias rst="restart"
alias homesteadconf="vim ~/Homestead/Homestead.yaml"
alias ubuntuconf="vim ~/ubuntu16/Vagrantfile"
alias dockremove="sudo apt remove gnome-shell-extension-ubuntu-dock"
alias dockinstall="sudo apt install gnome-shell-extension-ubuntu-dock"
alias lg="lazygit"
alias x="exit"
alias t="tmux"
alias tls="tmux ls"
alias tda="tmux kill-session -a"
alias tr="tmux kill-session -t"
alias alaconf="vim ~/.config/alacritty/alacritty.toml"
alias ghostconf="vim ~/.config/ghostty/config"
alias tmuxconf="vim ~/.tmux.conf"
alias kittyconf="vim ~/.config/kitty/kitty.conf"
alias kittydir="cd ~/.config/kitty"
alias delthemekit="rm -rf ~/.config/kitty/theme.conf"
alias sr="./node_modules/.bin/sequelize"
alias activated-php="sudo chown sheenazien:sheenazien /var/run/php/php7.0-fpm.sock"
alias at="alacritty-themes"
alias test_filter="./vendor/phpunit/phpunit/phpunit --filter"
alias testing="./vendor/phpunit/phpunit/phpunit"
alias i3config="vim ~/.config/i3/config"
alias vimdir="cd ~/.config/nvim"
alias perlight="sudo chmod a+rw /sys/class/backlight/intel_backlight/brightness"
alias capstoesc="/usr/bin/setxkbmap -option 'caps:swapescape'"
alias zshtheme="~/.oh-my-zsh/themes"
alias touchoff="synclient TouchpadOff=1"
alias touchon="synclient TouchpadOff=0"
alias symfony="~/.symfony/bin/symfony"
alias droidmote="curl -Ls https://www.videomap.it/script/install_droidmote_chromeos.sh | sudo sh"
alias xresources="vim ~/.config/regolith/Xresources"
alias ide="~/.config/commands/ide.sh"
alias ideconf="vim ~/.config/commandconfig.yml"
alias fusumaconf="vim ~/.config/fusuma/config.yml"
alias diarydir="cd ~/vimwiki/diary/"
alias diarytoday="vim ~/vimwiki/diary/$(date '+%Y-%m-%d').md"
alias commanddir="cd ~/.config/commands/"
alias switch-php="sudo update-alternatives --config php"
alias fixsound="sudo apt install -y libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev"
alias dbclient="nvim -c DBUI"
alias openconfig="vim ~/.config/opencode/config.json"
alias http="xh"

export PATH=~/.config/composer/vendor/bin:$PATH
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.yarn/bin
export PATH=$PATH:$HOME/go/bin


export PHPV="php -r 'echo phpversion()."\n";'"

export FZF_BASE="$HOME/.fzf"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Lando
export PATH="/Users/sheenazien8/.lando/bin${PATH+:$PATH}"; #landopath
# Flutter path
export PATH=$HOME/Documents/apps/flutter/bin:$PATH
# Android SDK Path
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP binary.
export PATH="/Users/sheenazien8/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/82/"


# Herd injected PHP 8.1 configuration.
export HERD_PHP_81_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/81/"


# Herd injected PHP 8.0 configuration.
export HERD_PHP_80_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/80/"


# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/74/"


export XDG_PICTURES_DIR="$HOME/Pictures"

export PATH="$PATH":"$HOME/.pub-cache/bin"

export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:"$HOME/.wakatime/"
export PATH=$PATH:"$HOME/.local/bin/"

# pnpm
export PNPM_HOME="/Users/sheenazien8/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export NVIM_CONFIG=~/.config/nvim

export HERD_PHP_84_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/84/"

. "$HOME/.limbo/env"


function update_tmux_session_name() {
  if [ -n "$TMUX" ]; then
    tmux rename-session "$(basename "$PWD")"
  fi
}

function update_tmux_window_name() {
  if [ -n "$TMUX" ]; then
    tmux rename-window "$(basename "$PWD")"
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd update_tmux_window_name
update_tmux_window_name  # call once on shell start

tmux-move-tab-to-session() {
  local current_session current_window_index window_name
  current_session=$(tmux display-message -p '#S')
  current_window_index=$(tmux display-message -p '#I')
  window_name=$(tmux display-message -p '#W')

  tmux new-session -d -s "$window_name"
  tmux move-window -s "${current_session}:${current_window_index}" -t "${window_name}:0"
  tmux switch-client -t "$window_name"
}

# [[ -f ~/.inshellisense/zsh/init.zsh ]] && source ~/.inshellisense/zsh/init.zsh
# create function for kill passed port
function killport() {
  kill -9 $(lsof -t -i :$1)
}

# opencode
export PATH=/Users/sheenazien8/.opencode/bin:$PATH

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.venvs/httpie/bin:$PATH"

# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/sheenazien8/Library/Application Support/Herd/config/php/85/"

export EDITOR=nvim

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=UTF-8


bindkey -M viins '^g' atuin-search

bindkey -M viins '^R' atuin-search
bindkey -M viins '^P' atuin-up-search
bindkey -M viins '^N' atuin-down-search

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(atuin init zsh)"

export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

bindkey -v
export KEYTIMEOUT=1


autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd m edit-command-line

export VI_MODE_SET_CURSOR=true

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q' # block
  else
    echo -ne '\e[6 q' # beam
  fi
}

zle -N zle-keymap-select

function zle-line-init() {
  zle -K viins
  echo -ne '\e[6 q'
}

zle -N zle-line-init

# atuin key => anger library warrior city float north record service index regular sniff mobile dentist student author north office aisle giraffe urge bone evoke kind fragile
export PATH=$PATH:$HOME/.local/bin
export PATH=/Library/TeX/texbin:$PATH
# export PATH=/Applications/Sublime Merge.app/Contents/MacOS/sublime_merge:$PATH

# bun completions
[ -s "/Users/sheenazien8/.bun/_bun" ] && source "/Users/sheenazien8/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


#compdef mysqlexec

_mysqlexec() {
  local -a completions
  local cur="${words[-1]}"

  completions=("${(@f)$(~/Documents/apps/mysql-shell-completion/mysql-shell-completion --complete "${words[*]:1}")}")
  compadd -- $completions
}

compdef _mysqlexec mysqlexec
source "$HOME/.cargo/env"
