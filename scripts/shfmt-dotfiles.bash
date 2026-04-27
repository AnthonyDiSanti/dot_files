#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

shell_files_helper="$repo_root/scripts/shell_files.bash"
args=(-i 2 -ci -bn)
files=()
repo_all=0
mode="diff"
status=0

if [[ ! -r "$shell_files_helper" ]]; then
  echo "shfmt-dotfiles: missing required helper: $shell_files_helper" >&2
  exit 1
fi
source "$shell_files_helper"

shfmt_bin="${SHFMT_BIN:-shfmt}"
if ! dotfiles_have_command "$shfmt_bin"; then
  echo "shfmt-dotfiles: shfmt not found" >&2
  exit 127
fi

usage() {
  cat <<'EOF'
Usage: scripts/shfmt-dotfiles.bash [--all] [--check|--diff|--write] [file ...]

  --all    Format/check all tracked sh/bash files managed by this repo.
  --check  Print diffs and fail if any file would change.
  --diff   Print diffs without rewriting files (default).
  --write  Rewrite files in place.
EOF
}

run_shfmt() {
  local shell="$1"
  shift

  "$shfmt_bin" "${args[@]}" -ln "$shell" "$@"
}

format_file() {
  local file="$1"
  local abs_path rel_path shell
  local shell_status
  local diff_output

  abs_path="$(dotfiles_shell_file_abs_path "$file")"
  rel_path="$(dotfiles_shell_file_rel_path "$repo_root" "$abs_path")"

  shell_status=0
  shell="$(dotfiles_shell_file_dialect "$abs_path" "$rel_path")" || shell_status=$?
  if ((shell_status != 0)); then
    echo "shfmt-dotfiles: unsupported shell file: $file" >&2
    return 2
  fi

  if [[ "$shell" == zsh ]]; then
    return 0
  fi

  if [[ "$shell" == sh ]]; then
    shell=posix
  fi

  case "$mode" in
    write)
      run_shfmt "$shell" -w "$file"
      ;;
    diff | check)
      if ! diff_output="$(run_shfmt "$shell" -d "$file")"; then
        printf '%s\n' "$diff_output"
        return 1
      fi
      if [[ -n "$diff_output" ]]; then
        printf '%s\n' "$diff_output"
        [[ "$mode" == diff ]] || return 1
      fi
      ;;
  esac
}

while (($#)); do
  case "$1" in
    --all)
      repo_all=1
      shift
      ;;
    --check)
      mode=check
      shift
      ;;
    --diff)
      mode="diff"
      shift
      ;;
    --write)
      mode="write"
      shift
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    --)
      shift
      files+=("$@")
      break
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
  usage >&2
  exit 2
fi

for file in "${files[@]}"; do
  format_file "$file" || status=$?
done

exit "$status"
