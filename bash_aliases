# General Aliases
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Git Aliases
alias gs='git status'

# Ruby Aliases
alias be='bundle exec'

# Functions
get_SCRIPTDIR () {
  local SOURCE="${BASH_SOURCE[0]}"
  local DIR="$( dirname "$SOURCE" )"
  while [ -h "$SOURCE" ]
  do 
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
  done
  SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}
