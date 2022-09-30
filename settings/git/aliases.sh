#!/usr/bin/env bash

# Abbreviation Aliases
git config --global alias.co 'checkout'
git config --global alias.subdo 'submodule foreach'
git config --global alias.ff 'merge --ff-only'
git config --global alias.cm 'commit -m'
git config --global alias.cam 'commit -am'
git config --global alias.ce 'commit -e'
git config --global alias.cae 'commit -ae'
git config --global alias.staged 'diff --cached'
git config --global alias.pu 'push -u origin HEAD'

# Helper Functions
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"
git config --global alias.wipe "!git clean -xdf; git reset --hard"

# List All Aliases
git config --global alias.alias "! git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /"

# UI Aliases
YELLOW='%C(yellow)'
RED='%C(red)'
CYAN='%C(cyan)'
RESET='%C(reset)'
git config --global alias.graph "log --graph --pretty=format:'$YELLOW%h$RESET -$RED%d$RESET %s $CYAN(%cr - %an)$RESET'"
