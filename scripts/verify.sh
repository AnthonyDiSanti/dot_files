#!/usr/bin/env bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
tmp_paths=()

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

mode_of() {
  stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1"
}

assert_mode() {
  local path="$1"
  local expected="$2"
  local actual

  actual="$(mode_of "$path")"
  [[ "$actual" == "$expected" ]] || fail "$path mode is $actual, expected $expected"
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
  sh -n "$repo_root/home/dot_profile"
  sh -n "$repo_root/home/dot_shrc"
  bash -n "$repo_root/home/dot_bash_profile"
  bash -n "$repo_root/home/dot_bashrc"
  sh -n "$repo_root/home/dot_config/shell/paths.sh"
  sh -n "$repo_root/home/dot_config/shell/profile.sh"
  sh -n "$repo_root/home/dot_config/shell/rc.sh"
  sh -n "$repo_root/home/dot_config/shell/aliases.sh"
  sh -n "$repo_root/home/dot_config/shell/functions.sh"
  bash -n "$repo_root/home/dot_config/bash/rc.bash"
  bash -n "$repo_root/home/dot_config/bash/prompt.bash"
  sh -n "$repo_root/home/dot_local/bin/make-chrome-app"

  zsh -n "$repo_root/home/dot_zprofile"
  zsh -n "$repo_root/home/dot_zshrc"
  zsh -n "$repo_root/home/dot_config/zsh/rc.zsh"
  zsh -n "$repo_root/home/dot_config/zsh/prompt.zsh"

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

  log "checking chezmoi managed target list"
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

  chezmoi --source "$repo_root" managed --path-style=relative | sort >"$actual"
  diff -u "$expected" "$actual"
}

check_temp_apply() {
  local tmp_home

  log "checking bootstrap in a temporary home"
  tmp_home="$(make_temp_dir)"
  HOME="$tmp_home" XDG_CONFIG_HOME="$tmp_home/.config" "$repo_root/bootstrap.sh" --verbose >/dev/null

  assert_mode "$tmp_home/.claude" 700
  assert_mode "$tmp_home/.codex" 700

  assert_symlink "$tmp_home/.profile" "$repo_root/home/dot_profile"
  assert_symlink "$tmp_home/.shrc" "$repo_root/home/dot_shrc"
  assert_symlink "$tmp_home/.bash_profile" "$repo_root/home/dot_bash_profile"
  assert_symlink "$tmp_home/.bashrc" "$repo_root/home/dot_bashrc"
  assert_symlink "$tmp_home/.zprofile" "$repo_root/home/dot_zprofile"
  assert_symlink "$tmp_home/.zshrc" "$repo_root/home/dot_zshrc"
  assert_symlink "$tmp_home/.config/shell/paths.sh" "$repo_root/home/dot_config/shell/paths.sh"
  assert_symlink "$tmp_home/.config/shell/profile.sh" "$repo_root/home/dot_config/shell/profile.sh"
  assert_symlink "$tmp_home/.config/shell/rc.sh" "$repo_root/home/dot_config/shell/rc.sh"
  assert_symlink "$tmp_home/.config/shell/aliases.sh" "$repo_root/home/dot_config/shell/aliases.sh"
  assert_symlink "$tmp_home/.config/shell/functions.sh" "$repo_root/home/dot_config/shell/functions.sh"
  assert_symlink "$tmp_home/.config/bash/rc.bash" "$repo_root/home/dot_config/bash/rc.bash"
  assert_symlink "$tmp_home/.config/bash/prompt.bash" "$repo_root/home/dot_config/bash/prompt.bash"
  assert_symlink "$tmp_home/.config/bash/git-prompt.sh" "$repo_root/lib/git/contrib/completion/git-prompt.sh"
  assert_symlink "$tmp_home/.config/bash/git-completion.bash" "$repo_root/lib/git/contrib/completion/git-completion.bash"
  assert_symlink "$tmp_home/.config/zsh/rc.zsh" "$repo_root/home/dot_config/zsh/rc.zsh"
  assert_symlink "$tmp_home/.config/zsh/prompt.zsh" "$repo_root/home/dot_config/zsh/prompt.zsh"
  assert_symlink "$tmp_home/.config/zsh/_git" "$repo_root/lib/git/contrib/completion/git-completion.zsh"
  assert_symlink "$tmp_home/.local/bin/make-chrome-app" "$repo_root/home/dot_local/bin/make-chrome-app"
  assert_symlink "$tmp_home/.claude/CLAUDE.md" "$repo_root/home/private_dot_claude/CLAUDE.md"
  assert_symlink "$tmp_home/.codex/AGENTS.md" "$repo_root/home/private_dot_codex/AGENTS.md"
  assert_symlink "$tmp_home/.codex/config.toml" "$repo_root/home/private_dot_codex/config.toml"
  assert_symlink "$tmp_home/.codex/rules/global.rules" "$repo_root/home/private_dot_codex/rules/global.rules"
  assert_symlink "$tmp_home/.gitignore_global" "$repo_root/home/dot_gitignore_global"
  assert_symlink "$tmp_home/.tmux.conf" "$repo_root/home/dot_tmux.conf"
  assert_symlink "$tmp_home/.vim" "$repo_root/home/.vim"
  assert_symlink "$tmp_home/.vimpagerrc" "$repo_root/home/dot_vimpagerrc"
  assert_symlink "$tmp_home/.vimrc" "$repo_root/home/dot_vimrc"
  assert_symlink "$tmp_home/.config/ghostty/config" "$repo_root/home/dot_config/ghostty/config"
}

check_live_home_converged() {
  local diff_output

  log "checking live home convergence"
  diff_output="$(make_temp_file)"
  "$repo_root/bootstrap.sh" --dry-run --verbose >"$diff_output"

  if [[ -s "$diff_output" ]]; then
    cat "$diff_output"
    fail "live home differs from chezmoi target state; run ./bootstrap.sh"
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
    zsh -lic '[[ "${DOTFILES_SHELL_RC_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_RC_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_PROMPT_LOADED:-0}" == 1 ]]; [[ "${DOTFILES_ZSH_COMPLETION_LOADED:-0}" == 1 ]]; [[ "${XDG_CONFIG_HOME:-}" == "$HOME/.config" ]]; [[ "${XDG_CACHE_HOME:-}" == "$HOME/.cache" ]]; [[ "${XDG_DATA_HOME:-}" == "$HOME/.local/share" ]]; [[ "${XDG_STATE_HOME:-}" == "$HOME/.local/state" ]]; [[ "${dotfiles_config_home:-}" == "$HOME/.config" ]]; [[ "${dotfiles_shell_config_home:-}" == "$HOME/.config/shell" ]]; [[ "${dotfiles_zsh_config_home:-}" == "$HOME/.config/zsh" ]]; [[ "${dotfiles_state_home:-}" == "$HOME/.local/state" ]]; [[ "${dotfiles_zsh_state_home:-}" == "$HOME/.local/state/zsh" ]]; [[ "${dotfiles_zsh_cache_home:-}" == "$HOME/.cache/zsh" ]]; [[ "${HISTFILE:-}" == "$HOME/.local/state/zsh/history" ]]; [[ "${HISTSIZE:-}" == 50000 ]]; [[ "${SAVEHIST:-}" == 50000 ]]; (( $+functions[_git] == 1 )); command -v make-chrome-app >/dev/null'
}

main() {
  require_command bash
  require_command chezmoi
  require_command diff
  require_command find
  require_command git
  require_command readlink
  require_command zsh

  cd "$repo_root"

  check_shell_syntax
  check_managed_targets
  check_temp_apply
  check_live_home_converged
  check_shell_startup

  log "checking chezmoi doctor"
  chezmoi --source "$repo_root" doctor --no-network >/dev/null

  log "all checks passed"
}

main "$@"
