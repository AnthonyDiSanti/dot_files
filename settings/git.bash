#!/usr/bin/env bash

# Settings
git config --global color.ui true
git config --global help.autocorrect 1
git config --global core.excludesfile ~/.gitignore_global

# Helper Aliases
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"

# git color-test
GIT_COLOR_RESET='%C(reset)'
declare -a GIT_COLORS=('normal' 'black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white')
declare -a GIT_COLOR_MODIFIERS=('bold' 'dim' 'ul' 'blink' 'reverse')
GIT_COLOR_TEST_FORMAT=''

for GIT_COLOR in ${GIT_COLORS[@]}; do
  GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT \n $GIT_COLOR_RESET%C($GIT_COLOR)$GIT_COLOR"
  for GIT_COLOR_MODIFIER in ${GIT_COLOR_MODIFIERS[@]}; do
    GIT_COLOR_TEST_FORMAT="$GIT_COLOR_TEST_FORMAT|$GIT_COLOR_RESET%C($GIT_COLOR $GIT_COLOR_MODIFIER)$GIT_COLOR $GIT_COLOR_MODIFIER"
  done
done

echo $GIT_COLOR_TEST_FORMAT

#git config --global alias.color-test "!git log -n1 --pretty=format:'$GIT_COLOR_TEST_FORMAT' | column -t -s\|"
git config --global alias.color-test "!git log -n1 --pretty=format:'$GIT_COLOR_TEST_FORMAT'"

#git config --global alias.color-test "!git log -n1 --pretty=format:'
#%C(normal)normal%C(reset)|%C(normal bold)normal bold%C(reset)|%C(normal dim)normal dim%C(reset)|%C(normal ul)normal ul%C(reset)|%C(normal blink)normal blink%C(reset)|%C(normal reverse)normal reverse%C(reset)
#%C(black)black%C(reset)|%C(black bold)black bold%C(reset)|%C(black dim)black dim%C(reset)|%C(black ul)black ul%C(reset)|%C(black blink)black blink%C(reset)|%C(black reverse)black reverse%C(reset)
#%C(red)red%C(reset)|%C(red bold)red bold%C(reset)|%C(red dim)red dim%C(reset)|%C(red ul)red ul%C(reset)|%C(red blink)red blink%C(reset)|%C(red reverse)red reverse%C(reset)
#%C(green)green%C(reset)|%C(green bold)green bold%C(reset)|%C(green dim)green dim%C(reset)|%C(green ul)green ul%C(reset)|%C(green blink)green blink%C(reset)|%C(green reverse)green reverse%C(reset)
#%C(yellow)yellow%C(reset)|%C(yellow bold)yellow bold%C(reset)|%C(yellow dim)yellow dim%C(reset)|%C(yellow ul)yellow ul%C(reset)|%C(yellow blink)yellow blink%C(reset)|%C(yellow reverse)yellow reverse%C(reset)
#%C(blue)blue%C(reset)|%C(blue bold)blue bold%C(reset)|%C(blue dim)blue dim%C(reset)|%C(blue ul)blue ul%C(reset)|%C(blue blink)blue blink%C(reset)|%C(blue reverse)blue reverse%C(reset)
#%C(magenta)magenta%C(reset)|%C(magenta bold)magenta bold%C(reset)|%C(magenta dim)magenta dim%C(reset)|%C(magenta ul)magenta ul%C(reset)|%C(magenta blink)magenta blink%C(reset)|%C(magenta reverse)magenta reverse%C(reset)
#%C(cyan)cyan%C(reset)|%C(cyan bold)cyan bold%C(reset)|%C(cyan dim)cyan dim%C(reset)|%C(cyan ul)cyan ul%C(reset)|%C(cyan blink)cyan blink%C(reset)|%C(cyan reverse)cyan reverse%C(reset)
#%C(white)white%C(reset)|%C(white bold)white bold%C(reset)|%C(white dim)white dim%C(reset)|%C(white ul)white ul%C(reset)|%C(white blink)white blink%C(reset)|%C(white reverse)white reverse%C(reset)
#' | column -t -s\|"

# UI Aliases
git config --global alias.showgraph "log --graph --abbrev-commit --pretty=oneline"
