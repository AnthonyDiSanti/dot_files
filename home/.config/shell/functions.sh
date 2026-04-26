exit_if_error() {
  dotfiles_exit_code=$?
  if [ "$dotfiles_exit_code" -ne 0 ]; then
    exit "$dotfiles_exit_code"
  fi
  return 0
}

dotfiles_codex_git() (
  dotfiles_repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
  dotfiles_git_common=$(git rev-parse --git-common-dir 2>/dev/null) || exit 1
  exec codex --add-dir "$HOME/.codex" -C "$dotfiles_repo_root" --add-dir "$dotfiles_git_common" "$@"
)

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
