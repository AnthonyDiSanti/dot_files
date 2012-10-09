# Determine directory script iis being executed
SOURCE="${BASH_SOURCE[0]}"
DIR="$( dirname "$SOURCE" )"
while [ -h "$SOURCE" ]
do 
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Enable color output
export CLICOLOR=1

# Set default applications
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Set shell hotkeys to vim
set -o vi

# Git autocomplete
source $DIR/.git-completion.bash

# Add the dot_files bin to PATH
export PATH=~/.bin:$PATH

# Define aliases
source $DIR/.bash_aliases

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
source $DIR/.git-prompt.sh

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1 ' (%s)') $Color_Off\! $ "

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
