#!/usr/bin/env bash

# Abbreviation Aliases
git config --global alias.cam "commit -am"

# Helper Aliases
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"

# UI Aliases
git config --global alias.graph "log --graph --abbrev-commit --pretty=oneline"
