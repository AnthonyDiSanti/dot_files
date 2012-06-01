# Enable color output
export CLICOLOR=1

# Define aliases
source ~/.bash_aliases

# Git autocomplete
source ~/.bash_git_autocomplete

# Setup prompt
Color_Off='\e[0m'       # Text Reset
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

export PS1="$Purple\u$Blue@\h $Green\w$Cyan\$(__git_ps1 ' (%s)') $Color_Off\! $ "

# Include local settings
if [ -r ~/.bash_local ]; then
  source ~/.bash_local
fi
