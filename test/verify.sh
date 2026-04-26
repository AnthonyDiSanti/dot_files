#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_root="$repo_root/test/fixtures/verify"
tmp_paths=()

if [[ ! -r "$repo_root/scripts/home_tree_manifest.sh" ]]; then
  echo "verify: missing required helper: $repo_root/scripts/home_tree_manifest.sh" >&2
  exit 1
fi
source "$repo_root/scripts/home_tree_manifest.sh"

if [[ ! -r "$repo_root/scripts/shell_files.bash" ]]; then
  echo "verify: missing required helper: $repo_root/scripts/shell_files.bash" >&2
  exit 1
fi
source "$repo_root/scripts/shell_files.bash"

cleanup() {
  local path

  if ((${#tmp_paths[@]} == 0)); then
    return 0
  fi

  for path in "${tmp_paths[@]}"; do
    rm -rf "$path"
  done
}

trap cleanup EXIT

log_suite() {
  printf '==> %s\n' "$1"
}

log_check() {
  printf '  - %s\n' "$1"
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

  log_check "shell syntax"

  while IFS= read -r -d '' script_path; do
    check_shell_file_syntax "$script_path"
  done < <(dotfiles_emit_tracked_shell_files "$repo_root")
}

check_shell_file_syntax() {
  local script_path="$1"
  local rel_path
  local shell

  [[ -f "$script_path" ]] || return 0

  rel_path="$(dotfiles_shell_file_rel_path "$repo_root" "$script_path")"
  shell="$(dotfiles_shell_file_dialect "$script_path" "$rel_path")" || return 0

  case "$shell" in
    bash)
      bash -n "$script_path"
      ;;
    zsh)
      zsh -n "$script_path"
      ;;
    sh)
      sh -n "$script_path"
      ;;
  esac

  # This helper is intentionally POSIX-shaped but sourced by zsh for Git's zsh wrapper.
  if [[ ${script_path#"$repo_root/"} == home/.config/bash/git-completion.sh ]]; then
    bash -n "$script_path"
    zsh -n "$script_path"
  fi
}

check_shell_lint() {
  log_check "shell static analysis"
  "$repo_root/scripts/shellcheck-dotfiles.bash" --all
}

check_shell_format() {
  log_check "shell formatting"
  "$repo_root/scripts/shfmt-dotfiles.bash" --all --check
}

check_managed_targets() {
  local expected
  local actual

  log_check "managed target list"
  expected="$(make_temp_file)"
  actual="$(make_temp_file)"

  dotfiles_emit_managed_paths "$repo_root" | sort >"$expected"
  "$repo_root/bootstrap.sh" --list-managed | sort >"$actual"
  diff -u "$expected" "$actual"
}

check_temp_apply() {
  local manifest_path
  local tmp_home
  local kind
  local rel_path
  local source_path

  log_check "bootstrap in a temporary home"
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

  log_check "live home convergence"
  diff_output="$(make_temp_file)"
  "$repo_root/bootstrap.sh" --dry-run --verbose >"$diff_output"

  if [[ -s "$diff_output" ]]; then
    cat "$diff_output"
    fail "live home differs from managed target state; run ./bootstrap.sh"
  fi
}

run_bash_fixture() {
  local fixture_name="$1"
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE="$fixture_root/$fixture_name" bash -lic 'source "$DOTFILES_VERIFY_FIXTURE"'
}

run_sh_fixture() {
  local fixture_name="$1"
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE="$fixture_root/$fixture_name" sh -lic '. "$DOTFILES_VERIFY_FIXTURE"'
}

run_zsh_fixture() {
  local fixture_name="$1"
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE="$fixture_root/$fixture_name" ZDOTDIR="$HOME" zsh -lic 'source "$DOTFILES_VERIFY_FIXTURE"'
}

assert_bash_startup() {
  run_bash_fixture bash-startup.bash "$@"
}

assert_bash_rerunnable() {
  run_bash_fixture bash-rerunnable.bash "$@"
}

assert_sh_startup() {
  run_sh_fixture sh-startup.sh "$@"
}

assert_sh_rerunnable() {
  run_sh_fixture sh-rerunnable.sh "$@"
}

assert_zsh_startup() {
  run_zsh_fixture zsh-startup.zsh "$@"
}

assert_zsh_rerunnable() {
  run_zsh_fixture zsh-rerunnable.zsh "$@"
}

check_shell_startup() {
  log_check "shell startup smoke tests"
  assert_sh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME

  assert_sh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1

  assert_sh_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME

  assert_bash_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE

  # Cursor can inherit exported sentinels from an older parent shell session.
  assert_bash_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1 \
    DOTFILES_BASH_RC_LOADED=1

  assert_bash_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE

  assert_zsh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST

  assert_zsh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1 \
    DOTFILES_ZSH_RC_LOADED=1 \
    DOTFILES_ZSH_PROMPT_LOADED=1 \
    DOTFILES_ZSH_COMPLETION_LOADED=1

  assert_zsh_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST
}

check_static_analysis_suite() {
  log_suite "static analysis"
  check_shell_syntax
  check_shell_lint
}

check_linting_suite() {
  log_suite "linting"
  check_shell_format
}

check_functionality_suite() {
  log_suite "functionality"
  check_managed_targets
  check_temp_apply
  check_live_home_converged
  check_shell_startup
}

main() {
  require_command awk
  require_command bash
  require_command comm
  require_command diff
  require_command git
  require_command readlink
  require_command shellcheck
  require_command shfmt
  require_command sort
  require_command zsh

  cd "$repo_root"

  # Keep verification grouped for scanability while retaining linear fail-fast execution.
  check_static_analysis_suite
  check_linting_suite
  check_functionality_suite

  log_suite "all checks passed"
}

main "$@"
