#!/usr/bin/env bash

# Settings
git config --global color.ui true
git config --global help.autocorrect 1
git config --global core.excludesfile ~/.gitignore_global

# Helper Aliases
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"

# git colors
GIT_COLOR_RESET='%C(reset)'
declare -a GIT_COLORS=('normal' 'black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white')
declare -a GIT_COLOR_MODIFIERS=('bold' 'dim' 'ul' 'blink' 'reverse')
GIT_COLOR_TEST_FORMAT=''
MAX_COLOR_LENGTH=0

for GIT_COLOR in ${GIT_COLORS[@]}; do
  if [[ ${#GIT_COLOR} > $MAX_COLOR_LENGTH ]]; then
    MAX_COLOR_LENGTH=${#GIT_COLOR}
  fi

  GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT%n%C($GIT_COLOR)$GIT_COLOR$GIT_COLOR_RESET"
  for GIT_COLOR_MODIFIER in ${GIT_COLOR_MODIFIERS[@]}; do
    GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT|%C($GIT_COLOR $GIT_COLOR_MODIFIER)$GIT_COLOR $GIT_COLOR_MODIFIER$GIT_COLOR_RESET"
  done
done

COLUMN_PADDING=3
AWK_FORMAT="%${MAX_COLOR_LENGTH}s"
for GIT_COLOR_MODIFIER in ${GIT_COLOR_MODIFIERS[@]}; do
  AWK_FORMAT="$AWK_FORMAT%$(($MAX_COLOR_LENGTH + $COLUMN_PADDING + ${#GIT_COLOR_MODIFIER} + 1))s"
done
AWK_FORMAT=$AWK_FORMAT'\n'

#AWK_SCRIPT='{ printf "'$AWK_FORMAT'", $1, $2, $3, $4, $5, $6 }'
AWK_SCRIPT="{ printf \"$AWK_FORMAT\""
AWK_SCRIPT=$AWK_SCRIPT', $1, $2, $3, $4, $5, $6 }'
echo $AWK_SCRIPT
git config --global alias.colors "!git log -n1 --pretty=format:'$GIT_COLOR_TEST_FORMAT' | awk -F\| '$AWK_SCRIPT'"

# UI Aliases
git config --global alias.graph "log --graph --abbrev-commit --pretty=oneline"
