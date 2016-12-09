#!/usr/bin/env bash

#gem install --no-ri --no-rdoc puppet

# http://stackoverflow.com/questions/59895/getting-the-current-present-working-directory-of-a-bash-script-from-within-the-s
dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FACTER_home_dir=~ FACTER_dotfiles_dir=$dotfiles_dir puppet apply site.pp
