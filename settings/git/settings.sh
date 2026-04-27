#!/usr/bin/env bash

git config --global color.ui true
git config --global help.autocorrect 1
git config --global core.excludesfile ~/.gitignore_global
git config --global push.default upstream

# git-spice Settings
git config --global spice.branchCreate.commit false
