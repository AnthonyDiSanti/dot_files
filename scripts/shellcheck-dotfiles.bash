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
repo_all=0
status=0

run_shellcheck() {
  local shellcheck_args=()

  if ((${#args[@]})); then
    shellcheck_args+=("${args[@]}")
  fi
  shellcheck_args+=("$@")

  "$shellcheck_bin" "${shellcheck_args[@]}"
}

shell_for_file() {
  local file="$1"
  local rel_path="$2"
  local first_line

  case "$rel_path" in
    home/.zprofile|home/.zshrc|home/.config/zsh/*.zsh|test/fixtures/verify/*.zsh)
      return 1
      ;;
    bootstrap.sh|home/.profile|home/.shrc|home/.local/bin/make-chrome-app)
      printf 'sh\n'
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
      *) run_shellcheck "$file"; return $? ;;
    esac
  fi

  case "$rel_path" in
    home/.config/bash/prompt.bash)
      extra_args+=(--exclude=SC2016 --exclude=SC2034)
      ;;
    scripts/print-ansi-colors.sh|settings/git/colors.sh)
      extra_args+=(--exclude=SC2016)
      ;;
    home/.config/bash/rc.bash)
      extra_args+=(--exclude=SC2154)
      ;;
    home/.config/shell/paths.sh)
      extra_args+=(--exclude=SC2034)
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

emit_repo_files() {
  local abs_path
  local rel_path
  local shell_status

  git -C "$repo_root" ls-files -z -- bootstrap.sh home scripts settings test |
    while IFS= read -r -d '' rel_path; do
      abs_path="$repo_root/$rel_path"
      [[ -f "$abs_path" ]] || continue

      # Keep --all scoped to files this wrapper knows how to classify or skip.
      shell_status=0
      shell_for_file "$abs_path" "$rel_path" >/dev/null || shell_status=$?
      case "$shell_status" in
        0|1) printf '%s\0' "$abs_path" ;;
      esac
    done
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

if ((repo_all)); then
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(emit_repo_files)
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
