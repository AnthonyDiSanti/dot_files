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
get_script_dir () {
  local SOURCE="${BASH_SOURCE[0]}"
  local DIR="$( dirname "$SOURCE" )"

  while [ -h "$SOURCE" ]; do 
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
  done

  local RETVAL="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  if [[ $# = 0 ]]; then
    SCRIPTDIR=$RETVAL
  else
    eval "$1='$RETVAL'"
  fi
}

get_script_dir DOTFILESDIR

# Define functions
for function in $DOTFILESDIR/bash/*; do
  source $function;
done

# Add the dot_files bin to PATH
export PATH=$DOTFILESDIR/bin:$PATH

# Setup prompt
Color_Prefix='\[\e['  # Required prefix for defining colors
Color_Suffix='\]'     # Required suffix for defining colors
Color_Off="${Color_Prefix}0m${Color_Suffix}"  # Text Reset
Black="${Color_Prefix}0;30m${Color_Suffix}"   # Black
Red="${Color_Prefix}0;31m${Color_Suffix}"     # Red
Green="${Color_Prefix}0;32m${Color_Suffix}"   # Green
Yellow="${Color_Prefix}0;33m${Color_Suffix}"  # Yellow
Blue="${Color_Prefix}0;34m${Color_Suffix}"    # Blue
Purple="${Color_Prefix}0;35m${Color_Suffix}"  # Purple
Cyan="${Color_Prefix}0;36m${Color_Suffix}"    # Cyan
White="${Color_Prefix}0;37m${Color_Suffix}"   # White

export GIT_PS1_SHOWDIRTYSTATE='auto'
export GIT_PS1_SHOWUNTRACKEDFILES='auto'
export GIT_PS1_SHOWUPSTREAM='auto'
source $DOTFILESDIR/bash/git-prompt.sh

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1 ' (%s)') $Color_Off\! $ "

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
