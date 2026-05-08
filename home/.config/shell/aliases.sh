# ls aliases
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias lld='lla | grep "^d"'
alias llf='lla | grep -v "^d"'

# cd aliases
# dash does not accept `alias --`, while bash/zsh need it for a `-` alias.
alias -- -='cd -' 2>/dev/null || alias '-=cd -'
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
alias gdiff='git diff'
alias gstat='git status'

# git-spice aliases
alias gs='git-spice'

# codex aliases
alias codex='codex --add-dir ~/.codex'
alias codex-git='dotfiles_codex_git'
