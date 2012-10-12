# Enable color output
export CLICOLOR=1

# Set default applications
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Set shell hotkeys to vim
set -o vi

# Finds the dereferenced directory of the current script
get_SCRIPTDIR () {
  local SOURCE="${BASH_SOURCE[0]}"
  local DIR="$( dirname "$SOURCE" )"
  while [ -h "$SOURCE" ]
  do 
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
  done
  SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

get_SCRIPTDIR

# Define functions
source $SCRIPTDIR/bash/functions.bash

# Define aliases
source $SCRIPTDIR/bash/aliases.bash

# Git autocomplete
source $SCRIPTDIR/bash/git-completion.bash

# Add the dot_files bin to PATH
export PATH=$SCRIPTDIR/bin:$PATH

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
source $SCRIPTDIR/bash/git-prompt.sh

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1 ' (%s)') $Color_Off\! $ "

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
