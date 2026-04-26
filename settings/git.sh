#!/usr/bin/env bash

# Finds the dereferenced directory of the current script
get_script_dir() {
  local SOURCE
  local DIR
  local RETVAL

  SOURCE="${BASH_SOURCE[0]}"
  DIR="$(dirname "$SOURCE")"

  while [ -h "$SOURCE" ]; do
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  done

  RETVAL="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  printf -v "$1" '%s' "$RETVAL"
}

get_script_dir GITSETTINGSDIR

source "$GITSETTINGSDIR/git/settings.sh"
source "$GITSETTINGSDIR/git/aliases.sh"
source "$GITSETTINGSDIR/git/colors.sh"
