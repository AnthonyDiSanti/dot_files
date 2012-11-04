#!/usr/bin/env bash

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

get_script_dir GITSETTINGSDIR

source $GITSETTINGSDIR/git/settings.bash
source $GITSETTINGSDIR/git/aliases.bash
source $GITSETTINGSDIR/git/colors.bash
