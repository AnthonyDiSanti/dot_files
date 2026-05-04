#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  CDPATH=
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
  pwd
)"
repo_root="$(
  CDPATH=
  cd -- "$script_dir/../.."
  pwd
)"
script_name=${0##*/}

source "$script_dir/lib/agent-harnesses.bash"

usage() {
  printf '%s\n' \
    'Usage: agents/scripts/symlink-all.bash [options] [skill-prefix]' \
    '' \
    'Symlinks selected runtime skill artifacts into selected harness home skill directories.' \
    '[skill-prefix] limits selection to source skills below agents/skills/src/<skill-prefix>.' \
    '' \
    'Options:' \
    '  --home HOME        Home tree to update (default: repo home/).' \
    '  --harness HARNESS  Limit to one harness; with --model, bypass home-config discovery.' \
    '  --model MODEL      Limit to one model; with --harness, bypass home-config discovery.' \
    '  --skill SKILL      Limit to one source skill directory name or src-relative path; can be repeated.' \
    '  --verbose          Show extra per-skill discovery details.' \
    '' \
    'With no filters, every source skill under agents/skills/src/ is selected.' \
    'Use either [skill-prefix] for a source subtree or --skill for explicit skills, not both.' \
    'Harness-owned model_aliases are normalized before artifact selection.'
}

die() {
  printf '%s: %s\n' "$script_name" "$*" >&2
  exit 2
}

log() {
  printf '%s\n' "$*"
}

count_lines() {
  local count=0
  local line

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    count=$((count + 1))
  done <<<"$1"

  printf '%s\n' "$count"
}

display_path() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s\n' "$PWD/$1" ;;
  esac
}

source_skills() {
  dotfiles_agent_source_skill_dirs "$repo_root"
}

validate_skill_prefix() {
  local prefix=$1

  case "$prefix" in
    '' | /* | . | ./ | ./* | ../* | */../* | */.. | */./* | */. | *//*)
      die "invalid source skill prefix: $prefix (expected a path relative to agents/skills/src/)"
      ;;
  esac
}

source_skills_with_prefix() {
  local prefix=${1%/}
  local skill_relpath
  local skills

  validate_skill_prefix "$prefix"
  skills="$(
    source_skills | while IFS= read -r skill_relpath; do
      [[ -n "$skill_relpath" ]] || continue
      case "$skill_relpath" in
        "$prefix" | "$prefix"/*)
          printf '%s\n' "$skill_relpath"
          ;;
      esac
    done
  )"

  [[ -n "$skills" ]] \
    || die "no source skills found under prefix: $prefix"
  printf '%s\n' "$skills"
}

selected_skills() {
  case "$skill_mode" in
    all)
      if [[ -n "$skill_prefix" ]]; then
        source_skills_with_prefix "$skill_prefix"
      else
        source_skills
      fi
      ;;
    explicit)
      printf '%s\n' "${explicit_skills[@]}"
      ;;
    *)
      die "unknown skill mode: $skill_mode"
      ;;
  esac
}

ensure_unique_skill_ids() {
  local skills=$1
  local duplicate_ids
  local duplicate_id
  local matches
  local skill_relpath

  duplicate_ids="$(
    while IFS= read -r skill_relpath; do
      [[ -n "$skill_relpath" ]] || continue
      dotfiles_agent_source_skill_id "$skill_relpath"
    done <<<"$skills" | LC_ALL=C sort | uniq -d
  )"

  while IFS= read -r duplicate_id; do
    [[ -n "$duplicate_id" ]] || continue
    matches="$(
      while IFS= read -r skill_relpath; do
        [[ -n "$skill_relpath" ]] || continue
        [[ "$(dotfiles_agent_source_skill_id "$skill_relpath")" == "$duplicate_id" ]] \
          || continue
        printf '%s\n' "$skill_relpath"
      done <<<"$skills"
    )"
    die "source skill directory name conflict: $duplicate_id is used by multiple src paths ($(dotfiles_agent_source_skill_format_paths <<<"$matches")); every source skill directory name must be globally unique because runtime artifacts use it as the skill id"
  done <<<"$duplicate_ids"
}

home_dir="$repo_root/home"
target_harness=''
target_model=''
skill_prefix=''
skill_mode=all
verbose=0
explicit_skills=()

while (($# > 0)); do
  case "$1" in
    --home)
      shift
      (($# > 0)) || die 'missing value for --home'
      home_dir=$1
      ;;
    --harness)
      shift
      (($# > 0)) || die 'missing value for --harness'
      target_harness=$1
      ;;
    --model)
      shift
      (($# > 0)) || die 'missing value for --model'
      target_model=$1
      ;;
    --skill)
      shift
      (($# > 0)) || die 'missing value for --skill'
      skill_mode=explicit
      explicit_skills+=("$1")
      ;;
    --verbose)
      verbose=1
      ;;
    -h | --help | help)
      usage
      exit 0
      ;;
    --*)
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$skill_prefix" ]] || die "unexpected argument: $1"
      skill_prefix=$1
      ;;
  esac
  shift
done

if [[ -n "$skill_prefix" && "$skill_mode" == explicit ]]; then
  die 'use either a skill prefix or --skill filters, not both'
fi

skills="$(selected_skills)"
[[ -n "$skills" ]] || die 'no source skills found'
ensure_unique_skill_ids "$skills"

log "Symlinking selected skills"
log "Home: $(display_path "$home_dir")"
log "Selected skills: $(count_lines "$skills")"

while IFS= read -r skill; do
  [[ -n "$skill" ]] || continue
  args=(--home "$home_dir")
  [[ -z "$target_harness" ]] || args+=(--harness "$target_harness")
  [[ -z "$target_model" ]] || args+=(--model "$target_model")
  ((verbose == 0)) || args+=(--verbose)
  DOTFILES_AGENT_SYMLINK_NO_SUMMARY=1 "$script_dir/symlink-skill.bash" "${args[@]}" "$skill"
done <<<"$skills"

log "Done: processed $(count_lines "$skills") skill(s)."
