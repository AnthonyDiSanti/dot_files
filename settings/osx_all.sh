#!/usr/bin/env sh

script_dir=$(
  unset CDPATH
  cd "$(dirname "$0")" && pwd
) || exit

. "$script_dir/osx_general.sh"
. "$script_dir/safari.sh"
. "$script_dir/iterm2.sh"
