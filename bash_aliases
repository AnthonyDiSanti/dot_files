# General Aliases
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias grep='grep --color=auto'

# Git Aliases
alias gs='git status'

# Ruby Aliases
alias be='bundle exec'

###### Functions ######
# Finds the dereferenced directory of the current script
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

# Exits a script if the previous command returned an error.  Exits with the same value the previous command returned.
exit_if_error () {
  RetCode=$?
  if [[ $RetCode -ne 0 ]]; then
    exit $RetCode
  else
    return 0
  fi
}
