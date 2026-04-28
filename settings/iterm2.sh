#!/usr/bin/env sh

profile_name="Solarized Dark (dotfiles)"
profile_guid="2F7D91E8-1D06-4CB3-A9AF-8C4D26D19C38"

echo "Set iTerm2 default profile to ${profile_name}"
# Dynamic profile contents are symlinked under home/; default selection is a global iTerm2 preference.
defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$profile_guid"

echo "Configure iTerm2 tmux integration to inherit the connecting session profile"
# Control-mode tmux should keep the Solarized profile instead of iTerm2's special tmux profile.
defaults write com.googlecode.iterm2 TmuxUsesDedicatedProfile -bool false
