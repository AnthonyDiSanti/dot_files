#!/usr/bin/env bash

dotfiles_agent_update_die() {
  printf '%s: %s\n' "${DOTFILES_AGENT_SCRIPT_NAME:-${0##*/}}" "$*" >&2
  exit 2
}

dotfiles_agent_update_is_verbose() {
  [[ "${DOTFILES_AGENT_VERBOSE:-0}" == 1 ]]
}

dotfiles_agent_update_is_quiet() {
  [[ "${DOTFILES_AGENT_QUIET:-0}" == 1 ]]
}

dotfiles_agent_update_log() {
  dotfiles_agent_update_is_quiet && return 0
  printf '%s\n' "$*"
}

dotfiles_agent_update_verbose_log() {
  dotfiles_agent_update_is_verbose || return 0
  dotfiles_agent_update_log "$@"
}

dotfiles_agent_update_print_file() {
  local file=$1
  local prefix=${2:-}

  [[ -s "$file" ]] || return 0
  if [[ -n "$prefix" ]]; then
    sed "s/^/$prefix/" "$file"
  else
    cat "$file"
  fi
}

dotfiles_agent_update_repo_relative() {
  local repo_root=$1
  local path=$2
  printf '%s\n' "${path#"$repo_root"/}"
}

dotfiles_agent_update_require_file() {
  local repo_root=$1
  local path=$2

  [[ -f "$path" ]] \
    || dotfiles_agent_update_die "missing required file: $(dotfiles_agent_update_repo_relative "$repo_root" "$path")"
}

dotfiles_agent_update_require_dir() {
  local repo_root=$1
  local path=$2

  [[ -d "$path" ]] \
    || dotfiles_agent_update_die "missing required directory: $(dotfiles_agent_update_repo_relative "$repo_root" "$path")"
}

dotfiles_agent_update_sed_replacement() {
  sed -e 's/[\/&|]/\\&/g' <<<"$1"
}

dotfiles_agent_update_validate_positive_integer() {
  local label=$1
  local value=$2

  case "$value" in
    '' | *[!0-9]*)
      dotfiles_agent_update_die "$label must be a positive integer: $value"
      ;;
  esac
  ((value > 0)) || dotfiles_agent_update_die "$label must be greater than zero: $value"
}

dotfiles_agent_update_validate_source_request() {
  local label=$1
  local requested=${2%/}

  case "$requested" in
    '' | /* | . | ./ | ./* | ../* | */../* | */.. | */./* | */. | *//*)
      dotfiles_agent_update_die "invalid $label path: $requested (expected a $label directory name or path relative to src/)"
      ;;
  esac
}

dotfiles_agent_update_resolve_source() {
  local repo_root=$1
  local source_root_rel=$2
  local marker_file=$3
  local label=$4
  local requested=${5%/}
  local exact_dir="$repo_root/$source_root_rel/$requested"
  local matches
  local count=0
  local match
  local one=''

  dotfiles_agent_update_validate_source_request "$label" "$requested"

  if [[ -f "$exact_dir/$marker_file" ]]; then
    printf '%s\n' "$requested"
    return 0
  fi

  matches="$(dotfiles_agent_source_matches "$repo_root" "$source_root_rel" "$marker_file" "$requested")"
  while IFS= read -r match; do
    [[ -n "$match" ]] || continue
    one=$match
    count=$((count + 1))
  done <<<"$matches"

  case "$count" in
    0)
      dotfiles_agent_update_die "unknown $label: $requested (expected a $label directory name or src-relative path)"
      ;;
    1)
      printf '%s\n' "$one"
      ;;
    *)
      dotfiles_agent_update_die "$label directory name conflict: $requested matches multiple src paths ($(dotfiles_agent_source_format_paths <<<"$matches")); every $label directory name must be globally unique because runtime artifacts use it as the id"
      ;;
  esac
}

dotfiles_agent_update_require_unique_source_id() {
  local repo_root=$1
  local source_root_rel=$2
  local marker_file=$3
  local label=$4
  local source_id=$5
  local matches
  local count=0
  local match

  matches="$(dotfiles_agent_source_matches "$repo_root" "$source_root_rel" "$marker_file" "$source_id")"
  while IFS= read -r match; do
    [[ -n "$match" ]] || continue
    count=$((count + 1))
  done <<<"$matches"

  ((count <= 1)) \
    || dotfiles_agent_update_die "$label directory name conflict: $source_id is used by multiple src paths ($(dotfiles_agent_source_format_paths <<<"$matches")); every $label directory name must be globally unique because runtime artifacts use it as the id"
}

dotfiles_agent_update_compute_digest() {
  local repo_root=$1
  local version_label=$2
  local input_file

  {
    printf '%s\n' "$version_label"
    while IFS= read -r input_file; do
      [[ -n "$input_file" ]] || continue
      printf 'path:%s\n' "$(dotfiles_agent_update_repo_relative "$repo_root" "$input_file")"
      shasum -a 256 "$input_file"
    done
  } | shasum -a 256 | awk '{print $1}'
}

dotfiles_agent_update_harness_skip_reason() {
  local repo_root=$1
  local harness=$2

  if dotfiles_agent_harness_is_installed "$repo_root" "$harness"; then
    return 1
  fi

  dotfiles_agent_harness_preflight "$repo_root" "$harness" \
    || dotfiles_agent_update_die 'invalid agent harness preflight policy'

  case "${DOTFILES_AGENT_HARNESS_MISSING_POLICY:-skip}" in
    skip)
      printf 'native target harness missing: %s' "$harness"
      return 0
      ;;
    fallback)
      return 1
      ;;
    *)
      dotfiles_agent_update_die "unsupported missing-harness policy: ${DOTFILES_AGENT_HARNESS_MISSING_POLICY:-}"
      ;;
  esac
}

dotfiles_agent_update_select_runner_harness() {
  local repo_root=$1
  local harness=$2

  if dotfiles_agent_harness_is_installed "$repo_root" "$harness"; then
    printf '%s\n' "$harness"
    return 0
  fi

  [[ "${DOTFILES_AGENT_HARNESS_MISSING_POLICY:-}" == fallback ]] \
    || dotfiles_agent_update_die "target harness is missing and fallback is not enabled: $harness"
  [[ -n "${DOTFILES_AGENT_HARNESS_FALLBACK:-}" ]] \
    || dotfiles_agent_update_die 'fallback harness was not selected'
  dotfiles_agent_harness_is_installed "$repo_root" "$DOTFILES_AGENT_HARNESS_FALLBACK" \
    || dotfiles_agent_update_die "fallback harness is not installed: $DOTFILES_AGENT_HARNESS_FALLBACK"

  printf '%s\n' "$DOTFILES_AGENT_HARNESS_FALLBACK"
}

dotfiles_agent_update_runner_args() {
  local repo_root=$1
  local runner_harness=$2
  local runner_arg

  while IFS= read -r runner_arg; do
    runner_arg=${runner_arg//\{\{repo_root\}\}/$repo_root}
    printf '%s\n' "$runner_arg"
  done < <(dotfiles_agent_harness_runner_args "$repo_root" "$runner_harness")
}
