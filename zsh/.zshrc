# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/sheena/.oh-my-zsh"
# powerlevel config
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true
# POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z composer fzf laravel fzf-tab)

source $ZSH/oh-my-zsh.sh


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# function custome
function homestead() {
    ( cd ~/Homestead && vagrant $* )
}
function ubuntu() {
    ( cd ~/ubuntu16 && vagrant $* )
}
composer-link() {
    composer config repositories.local '{"type": "path", "url": "'$1'"}' --file composer.json
}
#switch php version
function switch-php() {
    valet stop; sudo update-alternatives --set php /usr/bin/php$1; rm -f ~/.valet/valet.sock; valet install; valet use $1;
}
# jcAndRun() {
#   javac $i; java $i
# }
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias l='lsd -l'
alias la='lsd -a'
alias ls='lsd'
alias ll='lsd'
alias lla='lsd -la'
alias lt='lsd --tree'
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
alias alaconf="vim ~/.config/alacritty/alacritty.yml"
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
export PATH=~/.config/composer/vendor/bin:$PATH
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.yarn/bin
export PATH=$PATH:$HOME/go/bin


export PHPV="php -r 'echo phpversion()."\n";'"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# source /usr/share/doc/fzf/examples/completion.zsh
# source /usr/share/doc/fzf/examples/key-bindings.zsh

# export FZF_BASE=/usr/share/doc/fzf/
export FZF_BASE="$HOME/.fzf"
export TERM=xterm-256color
function my_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
zvm_after_init_commands+=(my_init)
