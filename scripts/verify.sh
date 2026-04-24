#!/usr/bin/env bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
tmp_paths=()

if [[ ! -r "$repo_root/scripts/home_tree_manifest.sh" ]]; then
  echo "verify: missing required helper: $repo_root/scripts/home_tree_manifest.sh" >&2
  exit 1
fi
source "$repo_root/scripts/home_tree_manifest.sh"

cleanup() {
  local path

  if (( ${#tmp_paths[@]} == 0 )); then
    return 0
  fi

  for path in "${tmp_paths[@]}"; do
    rm -rf "$path"
  done
}

trap cleanup EXIT

log() {
  printf '==> %s\n' "$1"
}

fail() {
  echo "verify: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required"
}

make_temp_file() {
  local path
  path="$(mktemp)"
  tmp_paths+=("$path")
  printf '%s\n' "$path"
}

make_temp_dir() {
  local path
  path="$(mktemp -d)"
  tmp_paths+=("$path")
  printf '%s\n' "$path"
}

assert_directory() {
  local path="$1"

  [[ -d "$path" ]] || fail "$path is not a directory"
  [[ ! -L "$path" ]] || fail "$path should be a real directory, not a symlink"
}

assert_symlink() {
  local path="$1"
  local expected="$2"
  local actual

  [[ -L "$path" ]] || fail "$path is not a symlink"
  actual="$(readlink "$path")"
  [[ "$actual" == "$expected" ]] || fail "$path points to $actual, expected $expected"
}

check_shell_syntax() {
  local script_path

  log "checking shell syntax"
  sh -n "$repo_root/bootstrap.sh"
  sh -n "$repo_root/home/.profile"
  sh -n "$repo_root/home/.shrc"
  bash -n "$repo_root/home/.bash_profile"
  bash -n "$repo_root/home/.bashrc"
  sh -n "$repo_root/home/.config/shell/paths.sh"
  sh -n "$repo_root/home/.config/shell/profile.sh"
  sh -n "$repo_root/home/.config/shell/rc.sh"
  sh -n "$repo_root/home/.config/shell/aliases.sh"
  sh -n "$repo_root/home/.config/shell/functions.sh"
  bash -n "$repo_root/home/.config/bash/rc.bash"
  bash -n "$repo_root/home/.config/bash/prompt.bash"
  sh -n "$repo_root/home/.local/bin/make-chrome-app"

  zsh -n "$repo_root/home/.zprofile"
  zsh -n "$repo_root/home/.zshrc"
  zsh -n "$repo_root/home/.config/zsh/rc.zsh"
  zsh -n "$repo_root/home/.config/zsh/prompt.zsh"

  # Parse-only: never executes the file, so `verify.sh` in this list does not re-enter the script.
  for script_path in "$repo_root"/scripts/*.sh; do
    [[ -e "$script_path" ]] || continue
    bash -n "$script_path"
  done

  for script_path in "$repo_root"/settings/*.sh "$repo_root"/settings/git/*.sh; do
    [[ -e "$script_path" ]] || continue
    bash -n "$script_path"
  done
}

check_managed_targets() {
  local expected
  local actual

  log "checking managed target list"
  expected="$(make_temp_file)"
  actual="$(make_temp_file)"

  cat >"$expected" <<'EOF'
.bash_profile
.bashrc
.claude
.claude/CLAUDE.md
.codex
.codex/AGENTS.md
.codex/config.toml
.codex/rules
.codex/rules/global.rules
.config
.config/bash
.config/bash/git-completion.bash
.config/bash/git-prompt.sh
.config/bash/prompt.bash
.config/bash/rc.bash
.config/ghostty
.config/ghostty/config
.config/shell
.config/shell/aliases.sh
.config/shell/functions.sh
.config/shell/paths.sh
.config/shell/profile.sh
.config/shell/rc.sh
.config/zsh
.config/zsh/_git
.config/zsh/prompt.zsh
.config/zsh/rc.zsh
.gitignore_global
.local
.local/bin
.local/bin/make-chrome-app
.profile
.shrc
.tmux.conf
.vim
.vimpagerrc
.vimrc
.zprofile
.zshrc
EOF

  sort -o "$expected" "$expected"
  "$repo_root/bootstrap.sh" --list-managed | sort >"$actual"
  diff -u "$expected" "$actual"
}

check_temp_apply() {
  local manifest_path
  local tmp_home
  local kind
  local rel_path
  local source_path

  log "checking bootstrap in a temporary home"
  tmp_home="$(make_temp_dir)"
  manifest_path="$(make_temp_file)"

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    "$repo_root/bootstrap.sh" --verbose >/dev/null

  dotfiles_emit_manifest "$repo_root" >"$manifest_path"

  while read -r kind rel_path source_path; do
    case "$kind" in
      dir)
        assert_directory "$tmp_home/$rel_path"
        ;;
      leaf)
        assert_symlink "$tmp_home/$rel_path" "$repo_root/$source_path"
        ;;
    esac
  done <"$manifest_path"
}

check_live_home_converged() {
  local diff_output

  log "checking live home convergence"
  diff_output="$(make_temp_file)"
  "$repo_root/bootstrap.sh" --dry-run --verbose >"$diff_output"

  if [[ -s "$diff_output" ]]; then
    cat "$diff_output"
    fail "live home differs from managed target state; run ./bootstrap.sh"
  fi
}

check_shell_startup() {
  log "checking shell startup smoke tests"
  env \
    -u DOTFILES_SHELL_PROFILE_LOADED \
    -u DOTFILES_SHELL_RC_LOADED \
    -u DOTFILES_BASH_RC_LOADED \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE \
    bash -lic '
    [[ "${DOTFILES_SHELL_RC_LOADED:-0}" == 1 ]]
    [[ "${DOTFILES_BASH_RC_LOADED:-0}" == 1 ]]
    [[ "${XDG_CONFIG_HOME:-}" == "$HOME/.config" ]]
    [[ "${XDG_CACHE_HOME:-}" == "$HOME/.cache" ]]
    [[ "${XDG_DATA_HOME:-}" == "$HOME/.local/share" ]]
    [[ "${XDG_STATE_HOME:-}" == "$HOME/.local/state" ]]
    [[ "${dotfiles_config_home:-}" == "$HOME/.config" ]]
    [[ "${dotfiles_shell_config_home:-}" == "$HOME/.config/shell" ]]
    [[ "${dotfiles_bash_config_home:-}" == "$HOME/.config/bash" ]]
    [[ "${dotfiles_state_home:-}" == "$HOME/.local/state" ]]
    [[ "${dotfiles_bash_state_home:-}" == "$HOME/.local/state/bash" ]]
    [[ "${HISTFILE:-}" == "$HOME/.local/state/bash/history" ]]
    [[ "${HISTSIZE:-}" == 50000 ]]
    [[ "${HISTFILESIZE:-}" == 50000 ]]
    if [[ -x /opt/homebrew/bin/brew ]]; then
      [[ "$(command -v brew 2>/dev/null)" == "/opt/homebrew/bin/brew" ]]
      [[ "${HOMEBREW_PREFIX:-}" == "/opt/homebrew" ]]
    elif [[ -x /usr/local/bin/brew ]]; then
      [[ "$(command -v brew 2>/dev/null)" == "/usr/local/bin/brew" ]]
      [[ "${HOMEBREW_PREFIX:-}" == "/usr/local" ]]
    fi
    command -v make-chrome-app >/dev/null
  '

  env \
    -u DOTFILES_SHELL_PROFILE_LOADED \
    -u DOTFILES_SHELL_RC_LOADED \
    -u DOTFILES_ZSH_RC_LOADED \
    -u DOTFILES_ZSH_PROMPT_LOADED \
    -u DOTFILES_ZSH_COMPLETION_LOADED \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST \
    ZDOTDIR="$HOME" \
    zsh -lic '[[ "${DOTFILES_SHELL_RC_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_RC_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_PROMPT_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_COMPLETION_LOADED:-0}" == 1 ]]; [[ "${XDG_CONFIG_HOME:-}" == "$HOME/.config" ]]; [[ "${XDG_CACHE_HOME:-}" == "$HOME/.cache" ]]; [[ "${XDG_DATA_HOME:-}" == "$HOME/.local/share" ]]; [[ "${XDG_STATE_HOME:-}" == "$HOME/.local/state" ]]; [[ "${dotfiles_config_home:-}" == "$HOME/.config" ]]; [[ "${dotfiles_shell_config_home:-}" == "$HOME/.config/shell" ]]; [[ "${dotfiles_zsh_config_home:-}" == "$HOME/.config/zsh" ]]; [[ "${dotfiles_state_home:-}" == "$HOME/.local/state" ]]; [[ "${dotfiles_zsh_state_home:-}" == "$HOME/.local/state/zsh" ]]; [[ "${dotfiles_zsh_cache_home:-}" == "$HOME/.cache/zsh" ]]; [[ "${HISTFILE:-}" == "$HOME/.local/state/zsh/history" ]]; [[ "${HISTSIZE:-}" == 50000 ]]; [[ "${SAVEHIST:-}" == 50000 ]]; if [[ -x /opt/homebrew/bin/brew ]]; then [[ "$(command -v brew 2>/dev/null)" == "/opt/homebrew/bin/brew" ]]; [[ "${HOMEBREW_PREFIX:-}" == "/opt/homebrew" ]]; elif [[ -x /usr/local/bin/brew ]]; then [[ "$(command -v brew 2>/dev/null)" == "/usr/local/bin/brew" ]]; [[ "${HOMEBREW_PREFIX:-}" == "/usr/local" ]]; fi; (( $+functions[_git] == 1 )); command -v make-chrome-app >/dev/null'
}

main() {
  require_command awk
  require_command bash
  require_command comm
  require_command diff
  require_command git
  require_command readlink
  require_command sort
  require_command zsh

  cd "$repo_root"

  check_shell_syntax
  check_managed_targets
  check_temp_apply
  check_live_home_converged
  check_shell_startup

  log "all checks passed"
}

main "$@"
