#!/usr/bin/env bash

git config --global color.ui true
git config --global help.autocorrect 1
git config --global core.excludesfile ~/.gitignore_global
git config --global alias.showgraph "log --graph --abbrev-commit --pretty=oneline"
git config --global alias.update-submodules "!echo 'Initing...'; git submodule init; echo '\nUpdating...'; git submodule update; echo '\nChecking out master...'; git submodule foreach git checkout master; echo '\nPulling...'; git submodule foreach git pull"
