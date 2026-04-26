#!/usr/bin/env bash

set -euo pipefail

shellcheck_bin="${SHELLCHECK_BIN:-shellcheck}"

if ! command -v "$shellcheck_bin" >/dev/null 2>&1; then
  echo "shellcheck-dotfiles: shellcheck not found" >&2
  exit 127
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
shell_files_helper="$repo_root/scripts/shell_files.bash"
args=()
files=()
repo_all=0
status=0

if [[ ! -r "$shell_files_helper" ]]; then
  echo "shellcheck-dotfiles: missing required helper: $shell_files_helper" >&2
  exit 1
fi
source "$shell_files_helper"

run_shellcheck() {
  local shellcheck_args=()

  if ((${#args[@]})); then
    shellcheck_args+=("${args[@]}")
  fi
  shellcheck_args+=("$@")

  "$shellcheck_bin" "${shellcheck_args[@]}"
}

lint_file() {
  local file="$1"
  local abs_path rel_path shell
  local shell_status
  local extra_args=()

  abs_path="$(dotfiles_shell_file_abs_path "$file")"
  rel_path="$(dotfiles_shell_file_rel_path "$repo_root" "$abs_path")"

  shell_status=0
  shell="$(dotfiles_shell_file_dialect "$abs_path" "$rel_path")" || shell_status=$?
  if ((shell_status != 0)); then
    run_shellcheck "$file"
    return $?
  fi

  if [[ "$shell" == zsh ]]; then
    return 0
  fi

  case "$rel_path" in
    home/.config/bash/prompt.bash)
      extra_args+=(--exclude=SC2016 --exclude=SC2034)
      ;;
    scripts/print-ansi-colors.sh | settings/git/colors.sh)
      extra_args+=(--exclude=SC2016)
      ;;
    home/.config/bash/rc.bash)
      extra_args+=(--exclude=SC2154)
      ;;
    home/.config/shell/paths.sh)
      extra_args+=(--exclude=SC2034)
      ;;
    home/.config/shell/profile.sh)
      extra_args+=(--exclude=SC3028)
      ;;
    test/verify.sh)
      extra_args+=(--exclude=SC2016)
      ;;
  esac

  if ((${#extra_args[@]})); then
    run_shellcheck --shell="$shell" "${extra_args[@]}" "$file"
  else
    run_shellcheck --shell="$shell" "$file"
  fi
}

while (($#)); do
  case "$1" in
    --all)
      repo_all=1
      shift
      ;;
    --)
      shift
      files+=("$@")
      break
      ;;
    -s | --shell)
      shift
      [[ $# -gt 0 ]] && shift
      continue
      ;;
    --shell=*)
      shift
      continue
      ;;
    -f | -e | -S | -o | -P | --format | --exclude | --severity | --enable | --source-path)
      args+=("$1")
      shift
      [[ $# -gt 0 ]] && args+=("$1") && shift
      ;;
    --format=* | --exclude=* | --severity=* | --enable=* | --source-path=*)
      args+=("$1")
      shift
      ;;
    -*)
      args+=("$1")
      shift
      ;;
    *)
      files+=("$1")
      shift
      ;;
  esac
done

if ((repo_all)); then
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(dotfiles_emit_tracked_shell_files "$repo_root")
fi

if ((${#files[@]} == 0)); then
  if ((${#args[@]})); then
    exec "$shellcheck_bin" "${args[@]}"
  fi
  exec "$shellcheck_bin"
fi

for file in "${files[@]}"; do
  lint_file "$file" || status=$?
done

exit "$status"
