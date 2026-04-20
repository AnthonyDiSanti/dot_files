export PATH=$PATH:~/bin
export EDITOR="vim -u NONE -N"
export VISUAL="$EDITOR"

alias codex='codex --add-dir ~/.codex'
codex-git() {
  local repo_root git_common
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  git_common="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  codex -C "$repo_root" --add-dir "$git_common" "$@"
}
