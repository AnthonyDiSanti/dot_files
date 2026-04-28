exit_if_error() {
  dotfiles_exit_code=$?
  if [ "$dotfiles_exit_code" -ne 0 ]; then
    exit "$dotfiles_exit_code"
  fi
  return 0
}

dotfiles_have_command() {
  # Hide command resolution output while preserving command lookup status.
  command -v "$1" >/dev/null 2>&1
}

dotfiles_command_succeeds() {
  # Capability probes execute commands; keep that side effect explicit in the name.
  [ "$#" -gt 0 ] || return 1
  dotfiles_have_command "$1" || return 1
  "$@" >/dev/null 2>&1
}

if command tmux -V >/dev/null 2>&1; then
  tmux() {
    dotfiles_tmux_control_mode=
    for dotfiles_tmux_arg; do
      if [ "$dotfiles_tmux_arg" = -CC ]; then
        dotfiles_tmux_control_mode=1
        break
      fi
    done

    # Make plain `tmux` converge on a stable workspace while preserving tmux subcommands.
    if [ "$#" -eq 0 ]; then
      command tmux new-session -A -s default
      unset dotfiles_tmux_arg dotfiles_tmux_control_mode
      return
    fi

    if [ -n "$dotfiles_tmux_control_mode" ]; then
      # Existing servers need to be safe before iTerm2 attaches a control-mode client.
      command tmux set-option -g focus-events off >/dev/null 2>&1 || :
      command tmux set-window-option -g aggressive-resize off >/dev/null 2>&1 || :
      DOTFILES_TMUX_CONTROL_MODE=1 command tmux "$@"
    else
      command tmux "$@"
    fi
    unset dotfiles_tmux_arg dotfiles_tmux_control_mode
  }
fi

dotfiles_codex_git() (
  dotfiles_repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
  dotfiles_git_common=$(git rev-parse --git-common-dir 2>/dev/null) || exit 1
  exec codex --add-dir "$HOME/.codex" -C "$dotfiles_repo_root" --add-dir "$dotfiles_git_common" "$@"
)

# Emit Homebrew prefixes that may contribute shell completions.
dotfiles_homebrew_prefix_roots() {
  dotfiles_homebrew_seen=
  dotfiles_homebrew_prefix=$(brew --prefix 2>/dev/null) || dotfiles_homebrew_prefix=
  if [ -n "$dotfiles_homebrew_prefix" ]; then
    printf '%s\n' "$dotfiles_homebrew_prefix"
    dotfiles_homebrew_seen=$dotfiles_homebrew_prefix
  fi

  for dotfiles_homebrew_prefix in /opt/homebrew /usr/local; do
    [ -x "$dotfiles_homebrew_prefix/bin/brew" ] || continue
    case ":$dotfiles_homebrew_seen:" in
      *:"$dotfiles_homebrew_prefix":*) ;;
      *)
        printf '%s\n' "$dotfiles_homebrew_prefix"
        dotfiles_homebrew_seen="${dotfiles_homebrew_seen:+$dotfiles_homebrew_seen:}$dotfiles_homebrew_prefix"
        ;;
    esac
  done

  unset dotfiles_homebrew_seen dotfiles_homebrew_prefix
}

# Emit share roots for the active Git install; shell-specific layers decide which helpers to load.
dotfiles_git_share_roots() {
  dotfiles_git_seen=
  dotfiles_git_html_path=$(git --html-path 2>/dev/null) || dotfiles_git_html_path=
  if [ -n "$dotfiles_git_html_path" ]; then
    dotfiles_git_share_root=$(dirname "$(dirname "$dotfiles_git_html_path")")
    case ":$dotfiles_git_seen:" in
      *:"$dotfiles_git_share_root":*) ;;
      *)
        printf '%s\n' "$dotfiles_git_share_root"
        dotfiles_git_seen="${dotfiles_git_seen:+$dotfiles_git_seen:}$dotfiles_git_share_root"
        ;;
    esac
  fi

  dotfiles_git_exec_path=$(git --exec-path 2>/dev/null) || dotfiles_git_exec_path=
  if [ -n "$dotfiles_git_exec_path" ]; then
    dotfiles_git_share_root=$(dirname "$(dirname "$dotfiles_git_exec_path")")/share
    case ":$dotfiles_git_seen:" in
      *:"$dotfiles_git_share_root":*) ;;
      *)
        printf '%s\n' "$dotfiles_git_share_root"
        dotfiles_git_seen="${dotfiles_git_seen:+$dotfiles_git_seen:}$dotfiles_git_share_root"
        ;;
    esac
  fi

  unset dotfiles_git_seen dotfiles_git_html_path dotfiles_git_exec_path dotfiles_git_share_root
}

# Emit install roots for the active Git install when helpers live outside the share tree.
dotfiles_git_prefix_roots() {
  dotfiles_git_seen=
  dotfiles_git_html_path=$(git --html-path 2>/dev/null) || dotfiles_git_html_path=
  if [ -n "$dotfiles_git_html_path" ]; then
    dotfiles_git_root=$(dirname "$(dirname "$(dirname "$dotfiles_git_html_path")")")
    case ":$dotfiles_git_seen:" in
      *:"$dotfiles_git_root":*) ;;
      *)
        printf '%s\n' "$dotfiles_git_root"
        dotfiles_git_seen="${dotfiles_git_seen:+$dotfiles_git_seen:}$dotfiles_git_root"
        ;;
    esac
  fi

  dotfiles_git_exec_path=$(git --exec-path 2>/dev/null) || dotfiles_git_exec_path=
  if [ -n "$dotfiles_git_exec_path" ]; then
    dotfiles_git_root=$(dirname "$(dirname "$dotfiles_git_exec_path")")
    case ":$dotfiles_git_seen:" in
      *:"$dotfiles_git_root":*) ;;
      *)
        printf '%s\n' "$dotfiles_git_root"
        dotfiles_git_seen="${dotfiles_git_seen:+$dotfiles_git_seen:}$dotfiles_git_root"
        ;;
    esac
  fi

  unset dotfiles_git_seen dotfiles_git_html_path dotfiles_git_exec_path dotfiles_git_root
}

# Emit prompt helper candidates for the active Git install.
dotfiles_git_prompt_candidates() {
  dotfiles_git_helper=git-prompt.sh

  while IFS= read -r dotfiles_git_share_root; do
    printf '%s\n' "$dotfiles_git_share_root/git-core/$dotfiles_git_helper"
  done <<EOF
$(dotfiles_git_share_roots)
EOF

  while IFS= read -r dotfiles_git_root; do
    printf '%s\n' "$dotfiles_git_root/etc/bash_completion.d/$dotfiles_git_helper"
  done <<EOF
$(dotfiles_git_prefix_roots)
EOF

  unset dotfiles_git_helper dotfiles_git_share_root dotfiles_git_root
}
