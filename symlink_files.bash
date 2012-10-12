#!/usr/bin/env bash

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

SYMLINKS=$(ls -1d $SCRIPTDIR/*.symlink)
for SYMLINK in $SYMLINKS
do
  BASENAME=$(basename $SYMLINK .symlink)
  ln -s $SYMLINK ~/.$BASENAME
done
