#!/usr/bin/env bash

if [ -r "$HOME/.profile" ]; then
  source "$HOME/.profile" || return 1
fi

case $- in
  *i*)
    if [ -r "$HOME/.bashrc" ]; then
      source "$HOME/.bashrc" || return 1
    fi
    ;;
esac

if [ -r "$HOME/.bash_profile_local" ]; then
  source "$HOME/.bash_profile_local" || return 1
fi
