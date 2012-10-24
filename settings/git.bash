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

for GIT_COLOR in ${GIT_COLORS[@]}; do
  GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT%n%C($GIT_COLOR)$GIT_COLOR$GIT_COLOR_RESET"
  for GIT_COLOR_MODIFIER in ${GIT_COLOR_MODIFIERS[@]}; do
    GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT|%C($GIT_COLOR $GIT_COLOR_MODIFIER)$GIT_COLOR $GIT_COLOR_MODIFIER$GIT_COLOR_RESET"
  done
done

AWK_FORMAT='%30s\n'
AWK_SCRIPT="{ printf \"$AWK_FORMAT\", \$3 }"
git config --global alias.colors "!git log -n1 --pretty=format:'$GIT_COLOR_TEST_FORMAT' | awk -F\| '$AWK_SCRIPT'"

# UI Aliases
git config --global alias.graph "log --graph --abbrev-commit --pretty=oneline"
