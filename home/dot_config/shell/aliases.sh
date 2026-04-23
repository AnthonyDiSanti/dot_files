# ls aliases
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias lld='lla | grep "^d"'
alias llf='lla | grep -v "^d"'

# cd aliases
alias -- -='cd -'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'

# dig aliases
alias digs='dig +short'

# color aliases
alias grep='grep --color=auto'

# git aliases
alias gd='git diff'
alias gs='git status'

# webpack aliases
alias wp='webpack --progress --colors'
alias ww='wp --watch'

# homebrew aliases
alias brewup='brew update && brew upgrade'

# codex aliases
alias codex='codex --add-dir ~/.codex'
alias codex-git='dotfiles_codex_git'
