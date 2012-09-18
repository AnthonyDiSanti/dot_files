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

# Bash Functions
exit_if_error () {
  RetCode=$?
  if [[ $RetCode -ne 0 ]]; then
    exit $RetCode
  else
    return 0;
  fi
}
