#!/usr/bin/env bash

set -euo pipefail

shellcheck_bin="${SHELLCHECK_BIN:-shellcheck}"

if ! command -v "$shellcheck_bin" >/dev/null 2>&1; then
  echo "shellcheck-dotfiles: shellcheck not found" >&2
  exit 127
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
args=()
files=()
status=0

shell_for_file() {
  local file="$1"
  local rel_path="$2"
  local first_line

  case "$rel_path" in
    home/.zprofile|home/.zshrc|home/.config/zsh/*.zsh|test/fixtures/verify/*.zsh)
      return 1
      ;;
    *.bash|home/.bash_profile|home/.bashrc)
      printf 'bash\n'
      ;;
    *.sh)
      first_line="$(sed -n '1p' "$file")"
      case "$first_line" in
        *bash*) printf 'bash\n' ;;
        *) printf 'sh\n' ;;
      esac
      ;;
    bootstrap.sh|home/.profile|home/.shrc|home/.local/bin/make-chrome-app)
      printf 'sh\n'
      ;;
    *)
      return 2
      ;;
  esac
}

lint_file() {
  local file="$1"
  local abs_path rel_path shell
  local shell_status
  local extra_args=()

  case "$file" in
    /*) abs_path="$file" ;;
    *) abs_path="$PWD/$file" ;;
  esac

  rel_path="${abs_path#"$repo_root"/}"

  shell_status=0
  shell="$(shell_for_file "$abs_path" "$rel_path")" || shell_status=$?
  if ((shell_status != 0)); then
    case "$shell_status" in
      1) return 0 ;;
      *) "$shellcheck_bin" "${args[@]}" "$file"; return $? ;;
    esac
  fi

  case "$rel_path" in
    home/.config/bash/prompt.bash|scripts/print-ansi-colors.sh)
      extra_args+=(--exclude=SC2016)
      ;;
  esac

  "$shellcheck_bin" "${args[@]}" --shell="$shell" "${extra_args[@]}" "$file"
}

while (($#)); do
  case "$1" in
    --)
      shift
      files+=("$@")
      break
      ;;
    -s|--shell)
      shift
      [[ $# -gt 0 ]] && shift
      continue
      ;;
    --shell=*)
      shift
      continue
      ;;
    -f|-e|-S|-o|-P|--format|--exclude|--severity|--enable|--source-path)
      args+=("$1")
      shift
      [[ $# -gt 0 ]] && args+=("$1") && shift
      ;;
    --format=*|--exclude=*|--severity=*|--enable=*|--source-path=*)
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

if ((${#files[@]} == 0)); then
  exec "$shellcheck_bin" "${args[@]}"
fi

for file in "${files[@]}"; do
  lint_file "$file" || status=$?
done

exit "$status"
