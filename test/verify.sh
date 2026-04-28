#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_root="$repo_root/test/fixtures/verify"
tmp_root="$(mktemp -d)"
tmp_paths=("$tmp_root")

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
  printf '  - %s' "$1"
}

format_duration() {
  local seconds="$1"

  awk -v seconds="$seconds" '
    BEGIN {
      if (seconds < 1) {
        milliseconds = int((seconds * 1000) + 0.5)
        if (milliseconds < 1) {
          print "<1ms"
        } else {
          printf "%dms\n", milliseconds
        }
      } else if (seconds < 10) {
        printf "%.2fs\n", seconds
      } else {
        printf "%.1fs\n", seconds
      }
    }
  '
}

run_timed_check() {
  local check_name="$1"
  local elapsed_file
  local elapsed_seconds
  local output_file
  local status
  local TIMEFORMAT="%3R"

  shift
  elapsed_file="$(make_temp_file)"
  output_file="$(make_temp_file)"

  log_check "$check_name"

  # Keep passing checks compact; replay captured output only when debugging a failure.
  set +e
  { time {
    (
      set -euo pipefail
      "$@"
    ) >"$output_file" 2>&1
  }; } 2>"$elapsed_file"
  status=$?
  set -e

  elapsed_seconds="$(<"$elapsed_file")"
  if ((status == 0)); then
    printf ' (%s)\n' "$(format_duration "$elapsed_seconds")"
  else
    printf ' (failed after %s)\n' "$(format_duration "$elapsed_seconds")"
  fi

  if ((status != 0)) && [[ -s "$output_file" ]]; then
    cat "$output_file"
  fi

  return "$status"
}

fail() {
  echo "verify: $*" >&2
  exit 1
}

require_command() {
  dotfiles_have_command "$1" || fail "$1 is required"
}

make_temp_file() {
  local path
  path="$(mktemp "$tmp_root/file.XXXXXX")"
  printf '%s\n' "$path"
}

make_temp_dir() {
  local path
  path="$(mktemp -d "$tmp_root/dir.XXXXXX")"
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
  "$repo_root/scripts/shellcheck-dotfiles.bash" --all
}

check_shell_format() {
  "$repo_root/scripts/shfmt-dotfiles.bash" --all --check
}

check_dev_tool_wrappers() {
  # VS Code probes ShellCheck with -V and may not use the workspace as cwd.
  (cd / && "$repo_root/scripts/shellcheck-dotfiles.bash" -V >/dev/null)
}

check_managed_targets() {
  local expected
  local actual

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

  run_bash_fixtures "$fixture_name" -- "$@"
}

run_sh_fixture() {
  local fixture_name="$1"
  shift

  run_sh_fixtures "$fixture_name" -- "$@"
}

run_zsh_fixture() {
  local fixture_name="$1"
  shift

  run_zsh_fixtures "$fixture_name" -- "$@"
}

run_bash_fixtures() {
  local fixture_names=()

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" bash -lic '
    set -e
    for fixture_name do
      DOTFILES_VERIFY_FIXTURE="$DOTFILES_VERIFY_FIXTURE_ROOT/$fixture_name"
      export DOTFILES_VERIFY_FIXTURE
      source "$DOTFILES_VERIFY_FIXTURE"
    done
  ' bash "${fixture_names[@]}"
}

run_sh_fixtures() {
  local fixture_names=()

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" sh -lic '
    set -e
    for fixture_name do
      DOTFILES_VERIFY_FIXTURE="$DOTFILES_VERIFY_FIXTURE_ROOT/$fixture_name"
      export DOTFILES_VERIFY_FIXTURE
      . "$DOTFILES_VERIFY_FIXTURE"
    done
  ' sh "${fixture_names[@]}"
}

run_zsh_fixtures() {
  local env_arg
  local fixture_names=()
  local zdotdir="$HOME"

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  for env_arg in "$@"; do
    case "$env_arg" in
      HOME=*)
        zdotdir="${env_arg#HOME=}"
        ;;
    esac
  done

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" ZDOTDIR="$zdotdir" zsh -lic '
    setopt ERR_EXIT
    for fixture_name do
      DOTFILES_VERIFY_FIXTURE="$DOTFILES_VERIFY_FIXTURE_ROOT/$fixture_name"
      export DOTFILES_VERIFY_FIXTURE
      source "$DOTFILES_VERIFY_FIXTURE"
    done
  ' zsh "${fixture_names[@]}"
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

check_zsh_vi_mode_operators() {
  local tmp_home

  tmp_home="$(make_temp_dir)"

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    XDG_CACHE_HOME="$tmp_home/.cache" \
    "$repo_root/bootstrap.sh" >/dev/null

  zsh "$fixture_root/zsh-vi-mode-operators.zsh" "$tmp_home"
}

assert_shell_startup_edge_cases() {
  local fixture_path
  local startup_stderr
  local tmux_log
  local tmp_home

  tmp_home="$(make_temp_dir)"
  startup_stderr="$(make_temp_file)"
  tmux_log="$(make_temp_file)"
  fixture_path="$fixture_root/fake-fzf-no-shell-support:$fixture_root/fake-generated-completion-no-support:${PATH:-}"

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    "$repo_root/bootstrap.sh" >/dev/null
  ln -s "$fixture_root/fake-tmux/tmux" "$tmp_home/.local/bin/tmux"

  run_sh_fixtures sh-startup.sh tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    HOME="$tmp_home" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>"$startup_stderr"

  run_bash_fixtures bash-startup.bash tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE \
    HOME="$tmp_home" \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>>"$startup_stderr"

  run_zsh_fixtures zsh-startup.zsh tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST \
    HOME="$tmp_home" \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>>"$startup_stderr"

  if grep -q "unknown option: --\\(bash\\|zsh\\)" "$startup_stderr"; then
    cat "$startup_stderr" >&2
    fail "unsupported fzf shell generators should not print startup errors"
  fi

  if grep -q "unknown command: completion" "$startup_stderr"; then
    cat "$startup_stderr" >&2
    fail "unsupported generated completions should not print startup errors"
  fi
}

check_shell_startup() {
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

  assert_shell_startup_edge_cases
}

check_static_analysis_suite() {
  log_suite "static analysis"
  run_timed_check "shell syntax" check_shell_syntax
  run_timed_check "shell static analysis" check_shell_lint
}

check_linting_suite() {
  log_suite "linting"
  run_timed_check "shell formatting" check_shell_format
}

check_functionality_suite() {
  log_suite "functionality"
  run_timed_check "dev tool wrappers" check_dev_tool_wrappers
  run_timed_check "managed target list" check_managed_targets
  run_timed_check "bootstrap in a temporary home" check_temp_apply
  run_timed_check "live home convergence" check_live_home_converged
  run_timed_check "shell startup smoke tests" check_shell_startup
  run_timed_check "zsh vi-mode operator smoke test" check_zsh_vi_mode_operators
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
