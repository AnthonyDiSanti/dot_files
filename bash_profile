# Enable color output
export CLICOLOR=1

# Set default applications
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Git autocomplete
source ~/.git-completion.bash

# Add the dot_files bin to PATH
export PATH=~/.bin:$PATH

# Define aliases
source ~/.bash_aliases

# Setup prompt
Color_Off='\e[0m'       # Text Reset
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

export GIT_PS1_SHOWDIRTYSTATE='auto'
export GIT_PS1_SHOWUNTRACKEDFILES='auto'
export GIT_PS1_SHOWUPSTREAM='auto'
source ~/.git-prompt.sh

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1 ' (%s)') $Color_Off\! $ "

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
