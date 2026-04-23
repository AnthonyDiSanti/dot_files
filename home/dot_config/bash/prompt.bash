# Setup prompt: ANSI SGR (raw) and paired PS_* wrappers (\[ \] for readline width on Bash PS1–PS4).
COLOR_PREFIX='\e['
BLACK="${COLOR_PREFIX}0;30m"
PS_BLACK="\\[${BLACK}\\]"
RED="${COLOR_PREFIX}0;31m"
PS_RED="\\[${RED}\\]"
GREEN="${COLOR_PREFIX}0;32m"
PS_GREEN="\\[${GREEN}\\]"
YELLOW="${COLOR_PREFIX}0;33m"
PS_YELLOW="\\[${YELLOW}\\]"
BLUE="${COLOR_PREFIX}0;34m"
PS_BLUE="\\[${BLUE}\\]"
PURPLE="${COLOR_PREFIX}0;35m"
PS_PURPLE="\\[${PURPLE}\\]"
CYAN="${COLOR_PREFIX}0;36m"
PS_CYAN="\\[${CYAN}\\]"
WHITE="${COLOR_PREFIX}0;37m"
PS_WHITE="\\[${WHITE}\\]"
COLOR_OFF="${COLOR_PREFIX}0m"
PS_OFF="\\[${COLOR_OFF}\\]"

BRIGHT_BLACK="${COLOR_PREFIX}90m"
PS_BRIGHT_BLACK="\\[${BRIGHT_BLACK}\\]"
BRIGHT_RED="${COLOR_PREFIX}91m"
PS_BRIGHT_RED="\\[${BRIGHT_RED}\\]"
BRIGHT_GREEN="${COLOR_PREFIX}92m"
PS_BRIGHT_GREEN="\\[${BRIGHT_GREEN}\\]"
BRIGHT_YELLOW="${COLOR_PREFIX}93m"
PS_BRIGHT_YELLOW="\\[${BRIGHT_YELLOW}\\]"
BRIGHT_BLUE="${COLOR_PREFIX}94m"
PS_BRIGHT_BLUE="\\[${BRIGHT_BLUE}\\]"
BRIGHT_MAGENTA="${COLOR_PREFIX}95m"
PS_BRIGHT_MAGENTA="\\[${BRIGHT_MAGENTA}\\]"
BRIGHT_CYAN="${COLOR_PREFIX}96m"
PS_BRIGHT_CYAN="\\[${BRIGHT_CYAN}\\]"
BRIGHT_WHITE="${COLOR_PREFIX}97m"
PS_BRIGHT_WHITE="\\[${BRIGHT_WHITE}\\]"

__dotfiles_git_prompt() {
  if declare -F __git_ps1 >/dev/null 2>&1; then
    __git_ps1
    return
  fi

  local ref

  ref="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" \
    || ref="$(git rev-parse --short HEAD 2>/dev/null)" \
    || return 0
  printf ' (%s)' "$ref"
}

# Job count in PS1: \j in static PS1 always shows, including 0. Only show the segment when
# count >= 1. We count from a file redirect (not $(...)), same path overwritten each time
# (we do not rm on exit; the file may linger until reboot, tmp, or manual removal; `$$` per shell).
# Use `jobs -r` + `jobs -s` (running + stopped) instead of `jobs -p` (PIDs). On stock macOS
# bash 3.2, a killed job can still have a defunct entry for one prompt, so PIDs can lag; -r/-s
# omit completed/terminated jobs, which matches the bracket segment we want to show.
#
# `\[ \]` in PS_* must be part of the same assignment that sets PS1. If a variable like
# ${PS1_JOBS} is expanded for promptvars on each prompt, those escapes are not treated as
# zero-width, so the prompt would show as literal `\[ \e[95m\]...`.
__dotfiles_set_ps1() {
  if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} == 0 ]]; then
    return
  fi

  local f n=0 ps1_jobs

  f="${TMPDIR:-/tmp}/.dotfiles_ps1_jobs_$$"
  ps1_jobs=''
  if builtin jobs -r >"$f" 2>/dev/null; then
    while IFS= read -r; do
      n=$((n + 1))
    done <"$f"
  fi
  if builtin jobs -s >"$f" 2>/dev/null; then
    while IFS= read -r; do
      n=$((n + 1))
    done <"$f"
  fi
  if ((n >= 1)); then
    ps1_jobs=" ${PS_BRIGHT_MAGENTA}[${n}]${PS_OFF}"
  fi
  # shellcheck disable=SC2016
  PS1="${PS_PURPLE}\u${PS_BLUE}@\h ${PS_GREEN}\w${PS_CYAN}\$(__dotfiles_git_prompt) ${PS_OFF}\!${ps1_jobs} ${PS_OFF}\$ "
  export PS1
}

case ";${PROMPT_COMMAND:-};" in
  *";__dotfiles_set_ps1;"*) ;;
  *) PROMPT_COMMAND="__dotfiles_set_ps1${PROMPT_COMMAND:+;${PROMPT_COMMAND}}" ;;
esac
