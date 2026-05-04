#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

args=()
files=()
repo_all=0
status=0

source "$repo_root/scripts/shell_files.bash"

shellcheck_bin="${SHELLCHECK_BIN:-shellcheck}"
if ! dotfiles_have_command "$shellcheck_bin"; then
  echo "shellcheck-dotfiles: shellcheck not found" >&2
  exit 127
fi

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

  run_shellcheck --shell="$shell" "$file"
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
