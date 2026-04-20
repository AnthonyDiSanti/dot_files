#!/usr/bin/env bash

# Enable color output
export CLICOLOR=1
export color_prompt=yes

# Set default applications
export EDITOR=vim
export VISUAL=vim
if hash vimpager 2>/dev/null; then
  export PAGER=vimpager
else
  export PAGER=less
fi

# Set shell hotkeys to vim
set -o vi

# Finds the dereferenced directory of the current script
get_repo_root () {
  local SOURCE="${BASH_SOURCE[0]}"
  local DIR="$( dirname "$SOURCE" )"

  while [ -h "$SOURCE" ]; do 
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
  done

  local RETVAL="$( cd -P "$( dirname "$SOURCE" )"/.. && pwd )"
  if [[ $# = 0 ]]; then
    SCRIPTDIR=$RETVAL
  else
    eval "$1='$RETVAL'"
  fi
}

get_repo_root DOTFILESDIR

# Define functions
for function in $DOTFILESDIR/bash/*; do
  source $function;
done

# Add the dot_files bin to PATH
export PATH=$DOTFILESDIR/bin:$PATH

# Setup prompt
Color_Prefix='\e['             # Required prefix for defining colors
Color_Off="${Color_Prefix}0m"  # Text Reset
Black="${Color_Prefix}0;30m"   # Black
Red="${Color_Prefix}0;31m"     # Red
Green="${Color_Prefix}0;32m"   # Green
Yellow="${Color_Prefix}0;33m"  # Yellow
Blue="${Color_Prefix}0;34m"    # Blue
Purple="${Color_Prefix}0;35m"  # Purple
Cyan="${Color_Prefix}0;36m"    # Cyan
White="${Color_Prefix}0;37m"   # White

export GIT_PS1_SHOWDIRTYSTATE='auto'
export GIT_PS1_SHOWUNTRACKEDFILES='auto'
export GIT_PS1_SHOWUPSTREAM='auto'
source $DOTFILESDIR/lib/git/contrib/completion/git-prompt.sh
source $DOTFILESDIR/lib/git/contrib/completion/git-completion.bash

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1) $Color_Off\! $ "
#export PS1="$Purple\u$Blue@\h $Green\w$Cyan $Color_Off\! $ "
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  echo -ne '\e[2 q' # Sets the cursor to a filled block
fi

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
