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

export DOTFILES_AGENT_SCRIPT_NAME="$script_name"
source "$script_dir/lib/agent-harnesses.bash"
source "$script_dir/lib/agent-updaters.bash"

usage() {
  printf '%s\n' \
    'Usage: agents/scripts/update-all.bash [options]' \
    '' \
    'Updates maintained agent artifacts across selected targets.' \
    '' \
    'Options:' \
    '  --type TYPE       Artifact type to update: skill or prompt (default: skill).' \
    '  --harness HARNESS  Limit to one harness; with --model, create the target if missing.' \
    '  --model MODEL      Limit to one model; with --harness, create the target if missing.' \
    '  --prompt PROMPT    Update one prompt across selected harness prompt artifacts.' \
    '  --force            Re-run selected targets during the first matrix pass.' \
    '  --max-passes N    Maximum fixed-point passes (default: 5).' \
    '  --verbose         Show current targets and successful child updater output.' \
    '' \
    'Skill mode discovers existing harness/model artifacts under agents/skills/artifacts/.' \
    'Prompt mode discovers existing harness prompt artifacts under agents/prompts/harnesses/.' \
    '--prompt without --type is shorthand for --type prompt --prompt PROMPT.'
}

die() {
  printf '%s: %s\n' "$script_name" "$*" >&2
  exit 1
}

repo_relative() {
  dotfiles_agent_update_repo_relative "$repo_root" "$1"
}

validate_positive_integer() {
  if ! dotfiles_agent_update_validate_positive_integer "$1" "$2"; then
    exit 1
  fi
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

run_child_command() {
  local output_file
  local status

  output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-agent-child.XXXXXX")"

  set +e
  DOTFILES_AGENT_QUIET=1 "$@" >"$output_file" 2>&1
  status=$?
  set -e

  if ((status != 0)); then
    dotfiles_agent_update_print_file "$output_file"
    rm -f "$output_file"
    return "$status"
  fi

  if dotfiles_agent_update_is_verbose; then
    dotfiles_agent_update_print_file "$output_file" '    '
  fi

  rm -f "$output_file"
}

source_skills() {
  dotfiles_agent_source_skill_dirs "$repo_root"
}

source_prompts() {
  dotfiles_agent_source_prompt_dirs "$repo_root"
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

ensure_unique_prompt_ids() {
  local prompts=$1
  local duplicate_ids
  local duplicate_id
  local matches
  local prompt_relpath

  duplicate_ids="$(
    while IFS= read -r prompt_relpath; do
      [[ -n "$prompt_relpath" ]] || continue
      dotfiles_agent_source_prompt_id "$prompt_relpath"
    done <<<"$prompts" | LC_ALL=C sort | uniq -d
  )"

  while IFS= read -r duplicate_id; do
    [[ -n "$duplicate_id" ]] || continue
    matches="$(
      while IFS= read -r prompt_relpath; do
        [[ -n "$prompt_relpath" ]] || continue
        [[ "$(dotfiles_agent_source_prompt_id "$prompt_relpath")" == "$duplicate_id" ]] \
          || continue
        printf '%s\n' "$prompt_relpath"
      done <<<"$prompts"
    )"
    die "source prompt directory name conflict: $duplicate_id is used by multiple src paths ($(dotfiles_agent_source_prompt_format_paths <<<"$matches")); every source prompt directory name must be globally unique because runtime artifacts use it as the id"
  done <<<"$duplicate_ids"
}

validate_target_filters() {
  if [[ -n "$target_harness" ]]; then
    dotfiles_agent_target_id_is_valid "$target_harness" \
      || die "invalid harness target id: $target_harness"
  fi
  if [[ -n "$target_model" ]]; then
    dotfiles_agent_target_id_is_valid "$target_model" \
      || die "invalid model target id: $target_model"
  fi
}

validate_prompt_filters() {
  validate_target_filters
  if [[ -n "$target_model" ]]; then
    die 'prompt artifacts are harness-scoped; --model only applies to skill updates'
  fi
}

selected_artifacts_or_die() {
  local selected
  selected="$(dotfiles_agent_select_artifacts "$repo_root" "$target_harness" "$target_model")"

  if [[ -n "$selected" ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  if [[ -n "$target_harness" && -z "$target_model" ]]; then
    die "no existing model artifacts found for harness: $target_harness (pass --model to create a specific harness/model target)"
  fi
  if [[ -z "$target_harness" && -n "$target_model" ]]; then
    die "no existing harness artifacts found for model: $target_model (pass --harness to create a specific harness/model target)"
  fi

  die 'no runtime artifacts found under agents/skills/artifacts/'
}

existing_prompt_harnesses() {
  local harness_dir
  local prompts_root="$repo_root/agents/prompts/harnesses"

  [[ -d "$prompts_root" ]] || return 0

  find "$prompts_root" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    | LC_ALL=C sort \
    | while IFS= read -r harness_dir; do
      printf '%s\n' "${harness_dir##*/}"
    done
}

selected_prompt_harnesses_or_die() {
  local selected

  if [[ -n "$target_harness" ]]; then
    printf '%s\n' "$target_harness"
    return 0
  fi

  selected="$(existing_prompt_harnesses)"
  if [[ -n "$selected" ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  die 'no prompt harness artifacts found under agents/prompts/harnesses/ (pass --harness to create a specific harness target)'
}

matrix_input_files() {
  local root

  for root in \
    "$repo_root/agents/skills/src" \
    "$repo_root/agents/skills/artifacts" \
    "$repo_root/agents/skills/.update-stamps" \
    "$repo_root/agents/prompts/src" \
    "$repo_root/agents/prompts/harnesses" \
    "$repo_root/agents/prompts/.update-stamps" \
    "$repo_root/agents/harnesses" \
    "$repo_root/agents/models"; do
    [[ -d "$root" ]] || continue
    find "$root" -type f
  done | LC_ALL=C sort
}

matrix_digest() {
  {
    printf 'dotfiles-agent-artifact-matrix-v2\n'
    matrix_input_files | while IFS= read -r input_file; do
      printf 'path:%s\n' "$(repo_relative "$input_file")"
      shasum -a 256 "$input_file"
    done
  } | shasum -a 256 | awk '{print $1}'
}

update_skill_for_artifact() {
  local selected_skill=$1
  local selected_artifact=$2
  local force_run=$3
  local artifact_harness
  local artifact_model
  local reason
  local reason_file
  local status

  checked_count=$((checked_count + 1))

  artifact_harness="$(dotfiles_agent_artifact_harness "$selected_artifact")" \
    || die "unsupported harness/model target: $selected_artifact"
  artifact_model="$(dotfiles_agent_artifact_model "$selected_artifact" "$artifact_harness")" \
    || die "missing model in harness/model target: $selected_artifact"

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-skip.XXXXXX")"
  set +e
  DOTFILES_AGENT_QUIET=1 "$script_dir/update-skill.bash" \
    --harness "$artifact_harness" \
    --model "$artifact_model" \
    --action should-skip \
    "$selected_skill" >"$reason_file" 2>&1
  status=$?
  set -e
  if ((status == 0)); then
    reason="$(<"$reason_file")"
    rm -f "$reason_file"
    skipped_count=$((skipped_count + 1))
    dotfiles_agent_update_log "  [skip] skill $selected_skill -> $selected_artifact: $reason"
    return 0
  fi
  if ((status != 1)); then
    dotfiles_agent_update_print_file "$reason_file"
    rm -f "$reason_file"
    exit "$status"
  fi
  rm -f "$reason_file"

  if "$script_dir/update-prompt.bash" \
    --harness "$artifact_harness" \
    --action is-stale \
    update-skill-artifact; then
    dotfiles_agent_update_log "  [prepare] prompt update-skill-artifact -> $artifact_harness"
    run_child_command "$script_dir/update-prompt.bash" \
      --harness "$artifact_harness" \
      --action run \
      update-skill-artifact
  else
    status=$?
    [[ "$status" -eq 1 ]] || exit "$status"
  fi

  if ((force_run == 1)); then
    updated_count=$((updated_count + 1))
    dotfiles_agent_update_log "  [force] skill $selected_skill -> $selected_artifact"
    run_child_command "$script_dir/update-skill.bash" \
      --harness "$artifact_harness" \
      --model "$artifact_model" \
      --action run \
      "$selected_skill"
    dotfiles_agent_update_log "  [done] skill $selected_skill -> $selected_artifact"
    return 0
  fi

  if "$script_dir/update-skill.bash" \
    --harness "$artifact_harness" \
    --model "$artifact_model" \
    --action is-stale \
    "$selected_skill"; then
    updated_count=$((updated_count + 1))
    dotfiles_agent_update_log "  [update] skill $selected_skill -> $selected_artifact"
    run_child_command "$script_dir/update-skill.bash" \
      --harness "$artifact_harness" \
      --model "$artifact_model" \
      --action run \
      "$selected_skill"
    dotfiles_agent_update_log "  [done] skill $selected_skill -> $selected_artifact"
    return 0
  else
    status=$?
    [[ "$status" -eq 1 ]] || exit "$status"
  fi

  current_count=$((current_count + 1))
  dotfiles_agent_update_verbose_log "  [ok] skill $selected_skill -> $selected_artifact"
}

update_prompt_for_harness() {
  local selected_prompt=$1
  local selected_harness=$2
  local force_run=$3
  local reason
  local reason_file
  local status

  checked_count=$((checked_count + 1))

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt-skip.XXXXXX")"
  set +e
  DOTFILES_AGENT_QUIET=1 "$script_dir/update-prompt.bash" \
    --harness "$selected_harness" \
    --action should-skip \
    "$selected_prompt" >"$reason_file" 2>&1
  status=$?
  set -e
  if ((status == 0)); then
    reason="$(<"$reason_file")"
    rm -f "$reason_file"
    skipped_count=$((skipped_count + 1))
    dotfiles_agent_update_log "  [skip] prompt $selected_prompt -> $selected_harness: $reason"
    return 0
  fi
  if ((status != 1)); then
    dotfiles_agent_update_print_file "$reason_file"
    rm -f "$reason_file"
    exit "$status"
  fi
  rm -f "$reason_file"

  if ((force_run == 1)); then
    updated_count=$((updated_count + 1))
    dotfiles_agent_update_log "  [force] prompt $selected_prompt -> $selected_harness"
    run_child_command "$script_dir/update-prompt.bash" \
      --harness "$selected_harness" \
      --action run \
      "$selected_prompt"
    dotfiles_agent_update_log "  [done] prompt $selected_prompt -> $selected_harness"
    return 0
  fi

  if "$script_dir/update-prompt.bash" \
    --harness "$selected_harness" \
    --action is-stale \
    "$selected_prompt"; then
    updated_count=$((updated_count + 1))
    dotfiles_agent_update_log "  [update] prompt $selected_prompt -> $selected_harness"
    run_child_command "$script_dir/update-prompt.bash" \
      --harness "$selected_harness" \
      --action run \
      "$selected_prompt"
    dotfiles_agent_update_log "  [done] prompt $selected_prompt -> $selected_harness"
    return 0
  else
    status=$?
    [[ "$status" -eq 1 ]] || exit "$status"
  fi

  current_count=$((current_count + 1))
  dotfiles_agent_update_verbose_log "  [ok] prompt $selected_prompt -> $selected_harness"
}

max_passes=5
force_update=0
verbose=0
target_harness=''
target_model=''
target_prompt=''
update_type=''
explicit_type=0

while (($# > 0)); do
  case "$1" in
    --type)
      shift
      (($# > 0)) || die 'missing value for --type'
      update_type=$1
      explicit_type=1
      ;;
    --max-passes)
      shift
      (($# > 0)) || die 'missing value for --max-passes'
      max_passes=$1
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
    --prompt)
      shift
      (($# > 0)) || die 'missing value for --prompt'
      target_prompt=$1
      if ((explicit_type == 0)); then
        update_type=prompt
      fi
      ;;
    --force)
      force_update=1
      ;;
    --verbose)
      verbose=1
      ;;
    --skill)
      die 'update-all.bash does not accept --skill; use update-skill.bash <skill> for skill-specific updates'
      ;;
    -h | --help | help)
      usage
      exit 0
      ;;
    --*)
      die "unknown option: $1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

update_type=${update_type:-skill}

case "$update_type" in
  skill | prompt) ;;
  *)
    die "unsupported artifact type: $update_type (expected skill or prompt)"
    ;;
esac

if [[ -n "$target_prompt" && "$update_type" != prompt ]]; then
  die '--prompt only applies to prompt updates'
fi

validate_positive_integer '--max-passes' "$max_passes"
if ((verbose == 1)); then
  export DOTFILES_AGENT_VERBOSE=1
fi
case "$update_type" in
  skill)
    validate_target_filters
    ;;
  prompt)
    validate_prompt_filters
    ;;
esac

checked_count=0
updated_count=0
current_count=0
skipped_count=0

pass=1
while ((pass <= max_passes)); do
  force_pass=0
  if ((force_update == 1 && pass == 1)); then
    force_pass=1
  fi

  dotfiles_agent_update_log "Updating $update_type artifacts (pass $pass)"

  before_digest="$(matrix_digest)"

  case "$update_type" in
    skill)
      artifacts="$(selected_artifacts_or_die)"
      skills="$(source_skills)"
      [[ -n "$skills" ]] || die 'no source skills found'
      ensure_unique_skill_ids "$skills"
      dotfiles_agent_update_log "Selected $(count_lines "$skills") skill(s) across $(count_lines "$artifacts") harness/model target(s)."

      while IFS= read -r artifact; do
        [[ -n "$artifact" ]] || continue
        while IFS= read -r skill; do
          [[ -n "$skill" ]] || continue
          update_skill_for_artifact "$skill" "$artifact" "$force_pass"
        done <<<"$skills"
      done <<<"$artifacts"
      ;;
    prompt)
      prompt_harnesses="$(selected_prompt_harnesses_or_die)"
      if [[ -n "$target_prompt" ]]; then
        prompts=$target_prompt
      else
        prompts="$(source_prompts)"
        [[ -n "$prompts" ]] || die 'no source prompts found'
        ensure_unique_prompt_ids "$prompts"
      fi
      dotfiles_agent_update_log "Selected $(count_lines "$prompts") prompt(s) across $(count_lines "$prompt_harnesses") harness target(s)."

      while IFS= read -r prompt; do
        [[ -n "$prompt" ]] || continue
        while IFS= read -r prompt_harness; do
          [[ -n "$prompt_harness" ]] || continue
          update_prompt_for_harness "$prompt" "$prompt_harness" "$force_pass"
        done <<<"$prompt_harnesses"
      done <<<"$prompts"
      ;;
  esac

  after_digest="$(matrix_digest)"
  if [[ "$after_digest" == "$before_digest" ]]; then
    dotfiles_agent_update_log "Done: checked $checked_count target(s); updated $updated_count, current $current_count, skipped $skipped_count. Fixed point after $pass pass(es)."
    exit 0
  fi

  pass=$((pass + 1))
done

die "did not reach a matrix fixed point after $max_passes pass(es)"
