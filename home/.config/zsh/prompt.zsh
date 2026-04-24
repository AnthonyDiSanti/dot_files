__dotfiles_zsh_escape_prompt_text() {
  emulate -L zsh
  local text="${1:-}"

  print -r -- "${text//\%/%%}"
}

__dotfiles_zsh_git_prompt() {
  emulate -L zsh
  local status_output line branch="" oid="" markers="" xy="" x="" y="" ab_values=""
  local staged=0 unstaged=0 untracked=0 has_upstream=0 ahead=0 behind=0
  local -a ab_fields

  status_output="$(command git status --porcelain=2 --branch 2>/dev/null)" || {
    branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" \
      || branch="$(command git rev-parse --short HEAD 2>/dev/null)" \
      || return 0
    branch="$(__dotfiles_zsh_escape_prompt_text "$branch")"
    print -r -- " (${branch})"
    return 0
  }

  while IFS= read -r line; do
    case $line in
      '# branch.head '*)
        branch=${line#'# branch.head '}
        ;;
      '# branch.oid '*)
        oid=${line#'# branch.oid '}
        ;;
      '# branch.upstream '*)
        has_upstream=1
        ;;
      '# branch.ab '*)
        ab_values=${line#'# branch.ab '}
        ab_fields=(${=ab_values})
        if (( ${#ab_fields} >= 2 )); then
          ahead=${ab_fields[1]#+}
          behind=${ab_fields[2]-}
        fi
        ;;
      [12u]' '*)
        xy=${line[3,4]}
        x=${xy[1,1]}
        y=${xy[2,2]}
        [[ $x != "." ]] && staged=1
        [[ $y != "." ]] && unstaged=1
        ;;
      \?*)
        untracked=1
        ;;
    esac
  done <<< "$status_output"

  if [[ -z $branch || $branch == "(detached)" ]]; then
    if [[ -n $oid && $oid != "(initial)" && $oid != "(unknown)" ]]; then
      branch=${oid[1,7]}
    else
      branch="$(command git rev-parse --short HEAD 2>/dev/null)" || branch=""
    fi
  fi

  [[ -n $branch ]] || return 0
  branch="$(__dotfiles_zsh_escape_prompt_text "$branch")"

  (( unstaged )) && markers+="*"
  (( staged )) && markers+="+"
  (( untracked )) && markers+="%%"

  if (( has_upstream )); then
    if (( ahead > 0 && behind > 0 )); then
      markers+="<>"
    elif (( ahead > 0 )); then
      markers+=">"
    elif (( behind > 0 )); then
      markers+="<"
    else
      markers+="="
    fi
  fi

  if [[ -n $markers ]]; then
    print -r -- " (${branch} ${markers})"
  else
    print -r -- " (${branch})"
  fi
}

__dotfiles_zsh_precmd() {
  local last_status=$?
  emulate -L zsh
  local job_count=${#jobstates}

  DOTFILES_ZSH_LAST_STATUS=$last_status

  if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} == 0 ]]; then
    return $last_status
  fi

  DOTFILES_ZSH_GIT_PROMPT="$(__dotfiles_zsh_git_prompt)"

  if (( job_count >= 1 )); then
    DOTFILES_ZSH_JOBS_PROMPT=" %F{13}[${job_count}]%f"
  else
    DOTFILES_ZSH_JOBS_PROMPT=""
  fi

  return $last_status
}

if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} != 0 ]]; then
  autoload -Uz add-zsh-hook
  setopt prompt_subst
  PROMPT='%F{magenta}%n%F{blue}@%m %F{green}%~%F{cyan}${DOTFILES_ZSH_GIT_PROMPT} %f%!${DOTFILES_ZSH_JOBS_PROMPT} %f%(!.#.$) '
  add-zsh-hook -d precmd __dotfiles_zsh_precmd 2>/dev/null || true
  add-zsh-hook precmd __dotfiles_zsh_precmd
  __dotfiles_zsh_precmd
fi
