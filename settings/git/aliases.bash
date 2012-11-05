#!/usr/bin/env bash

# Abbreviation Aliases
git config --global alias.cam "commit -am"

# Helper Aliases
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"

# UI Aliases
YELLOW='%C(yellow)'
RED='%C(red)'
CYAN='%C(cyan)'
RESET='%C(reset)'
git config --global alias.graph "log --graph --pretty=format:'$YELLOW%h$RESET -$RED%d$RESET %s $CYAN(%cr - %an)$RESET'"
