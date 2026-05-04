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
tmp_paths=()

# Shared production-run preflight keeps missing harness policy consistent across
# one-target and aggregate update entrypoints.
export DOTFILES_AGENT_SCRIPT_NAME="$script_name"
source "$script_dir/lib/agent-harnesses.bash"
source "$script_dir/lib/agent-updaters.bash"

cleanup() {
  ((${#tmp_paths[@]} == 0)) || rm -f "${tmp_paths[@]}"
}
trap cleanup EXIT

usage() {
  printf '%s\n' \
    'Usage:' \
    '  agents/scripts/update-skill.bash [options] <skill>' \
    '' \
    'Updates one source skill across selected harness/model artifacts.' \
    '<skill> may be a globally unique skill directory name or a path relative to agents/skills/src/.' \
    '' \
    'Options:' \
    '  --harness HARNESS    Limit to one harness; with --model, create the target if missing.' \
    '  --model MODEL        Limit to one model across existing artifacts; with --harness, create if missing.' \
    '  --action ACTION      check, status, is-stale, print-prompt, run, run-if-stale, record-stamp, should-skip.' \
    '  --force              Re-run selected targets during the first run-if-stale pass.' \
    '  --max-passes N      Maximum fixed-point passes for run-if-stale (default: 5).' \
    '  --verbose           Show nested updater details and successful native harness output.' \
    '' \
    'Defaults:' \
    '  ACTION defaults to run-if-stale.' \
    '  With no --harness/--model, existing artifacts under agents/skills/artifacts/ are selected.' \
    '  --harness without --model selects existing models for that harness.' \
    '  --model without --harness selects existing harnesses for that model.' \
    '  Harness-owned model_aliases are normalized before artifact selection.'
}

die() {
  dotfiles_agent_update_die "$@"
}

require_file() {
  dotfiles_agent_update_require_file "$repo_root" "$1"
}

require_dir() {
  dotfiles_agent_update_require_dir "$repo_root" "$1"
}

sed_replacement() {
  dotfiles_agent_update_sed_replacement "$1"
}

repo_relative() {
  dotfiles_agent_update_repo_relative "$repo_root" "$1"
}

validate_positive_integer() {
  dotfiles_agent_update_validate_positive_integer "$1" "$2"
}

resolve_source_skill() {
  dotfiles_agent_update_resolve_source "$repo_root" agents/skills/src SKILL.md 'source skill' "$1"
}

require_unique_source_skill_id() {
  dotfiles_agent_update_require_unique_source_id "$repo_root" agents/skills/src SKILL.md 'source skill' "$1"
}

configure_skill() {
  requested_skill=$1
  skill_source_relpath="$(resolve_source_skill "$requested_skill")"
  skill="$(dotfiles_agent_source_skill_id "$skill_source_relpath")"
  dotfiles_agent_target_id_is_valid "$skill" \
    || die "invalid source skill directory name: $skill (use only letters, numbers, dots, underscores, and hyphens)"
  require_unique_source_skill_id "$skill"
  skill_dir="$repo_root/agents/skills/src/$skill_source_relpath"
  source_skill="$skill_dir/SKILL.md"
  eval_dir="$skill_dir/evals"
  harness_notes_dir="$skill_dir/harness-notes"
  model_notes_dir="$skill_dir/model-notes"

  require_dir "$skill_dir"
  require_file "$source_skill"
}

configure_artifact() {
  local requested_skill=$1
  local requested_artifact=$2

  configure_skill "$requested_skill"

  artifact=$requested_artifact
  harness="$(dotfiles_agent_artifact_harness "$artifact")" \
    || die "unsupported harness/model target: $artifact (expected <harness>/<model>)"
  model="$(dotfiles_agent_artifact_model "$artifact" "$harness")" \
    || die "missing model in harness/model target: $artifact (expected <harness>/<model>)"

  [[ -n "$model" ]] \
    || die "missing model in harness/model target: $artifact (expected <harness>/<model>)"

  artifact_dir="$repo_root/agents/skills/artifacts/$artifact/skills/$skill"
  harness_notes="$harness_notes_dir/${harness}.md"
  model_notes="$model_notes_dir/${model}.md"
  template="$repo_root/agents/prompts/harnesses/${harness}/update-skill-artifact.md"
  harness_config="$repo_root/agents/harnesses/${harness}.yaml"
  harness_guide="$repo_root/agents/harnesses/${harness}.md"
  model_guide="$repo_root/agents/models/${model}.md"

  artifact_stamp_dir="$repo_root/agents/skills/.update-stamps/$artifact/skills/$skill"
  artifact_stamp="$artifact_stamp_dir/inputs.sha256"
}

supported_models() {
  local guide
  local model_name

  find "$repo_root/agents/models" \
    -maxdepth 1 \
    -type f \
    -name '*.md' \
    | LC_ALL=C sort \
    | while IFS= read -r guide; do
      model_name="${guide##*/}"
      model_name="${model_name%.md}"
      [[ "$model_name" == README ]] && continue
      printf '%s\n' "$model_name"
    done
}

supported_harnesses() {
  dotfiles_agent_harnesses "$repo_root"
}

require_supported_harness() {
  if [[ -f "$harness_config" ]]; then
    return 0
  fi

  local supported
  supported="$(supported_harnesses | tr '\n' ' ')"
  supported="${supported% }"

  if [[ -n "$supported" ]]; then
    die "unsupported harness target: $harness (missing config: $(repo_relative "$harness_config"); supported harnesses: $supported)"
  fi

  die "unsupported harness target: $harness (missing config: $(repo_relative "$harness_config"); no harness configs found)"
}

require_supported_model() {
  if [[ -f "$model_guide" ]]; then
    return 0
  fi

  local supported
  supported="$(supported_models | tr '\n' ' ')"
  supported="${supported% }"

  if [[ -n "$supported" ]]; then
    die "unsupported model for $harness target: $model (missing guide: $(repo_relative "$model_guide"); supported models: $supported)"
  fi

  die "unsupported model for $harness target: $model (missing guide: $(repo_relative "$model_guide"); no model guides found)"
}

check_inputs() {
  require_file "$source_skill"
  require_supported_harness
  require_file "$harness_guide"
  require_supported_model
  require_file "$template"
}

ensure_skill_prompt_current() {
  local output_file
  local status

  output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-prompt-update.XXXXXX")"
  tmp_paths+=("$output_file")

  set +e
  DOTFILES_AGENT_QUIET=1 "$script_dir/update-prompt.bash" \
    --harness "$harness" \
    --action run-if-stale \
    update-skill-artifact >"$output_file" 2>&1
  status=$?
  set -e

  if ((status != 0)); then
    dotfiles_agent_update_print_file "$output_file"
    die "failed to refresh updater prompt for harness: $harness"
  fi

  if dotfiles_agent_update_is_verbose; then
    dotfiles_agent_update_print_file "$output_file" '    '
  fi
}

artifact_output_files() {
  local output
  local output_count=0

  while IFS= read -r output; do
    [[ -n "$output" ]] || continue
    output_count=$((output_count + 1))
    printf '%s\n' "$artifact_dir/$output"
  done < <(dotfiles_agent_harness_outputs "$repo_root" "$harness")

  ((output_count > 0)) \
    || die "no outputs configured for harness: $harness ($(repo_relative "$harness_config"))"
}

ensure_output_dirs() {
  local output_file

  artifact_output_files | while IFS= read -r output_file; do
    mkdir -p "$(dirname -- "$output_file")"
  done
}

check_outputs() {
  local output_file
  artifact_output_files | while IFS= read -r output_file; do
    require_file "$output_file"
  done
}

input_files() {
  printf '%s\n' \
    "$source_skill" \
    "$harness_config" \
    "$harness_guide" \
    "$model_guide" \
    "$template"

  if [[ -f "$harness_notes" ]]; then
    printf '%s\n' "$harness_notes"
  fi

  if [[ -f "$model_notes" ]]; then
    printf '%s\n' "$model_notes"
  fi

  if [[ -d "$eval_dir" ]]; then
    find "$eval_dir" -type f | LC_ALL=C sort
  fi
}

compute_input_digest() {
  input_files | dotfiles_agent_update_compute_digest "$repo_root" 'dotfiles-skill-artifact-inputs-v2'
}

write_stamp() {
  mkdir -p "$artifact_stamp_dir"
  compute_input_digest >"$artifact_stamp"
}

stale_reason() {
  check_inputs

  local output_file
  while IFS= read -r output_file; do
    if [[ ! -f "$output_file" ]]; then
      printf 'missing output: %s\n' "$(repo_relative "$output_file")"
      return 0
    fi
  done < <(artifact_output_files)

  if [[ ! -f "$artifact_stamp" ]]; then
    printf 'missing input digest stamp: %s\n' "$(repo_relative "$artifact_stamp")"
    return 0
  fi

  local expected_digest
  local actual_digest
  expected_digest="$(compute_input_digest)"
  actual_digest="$(<"$artifact_stamp")"

  if [[ "$actual_digest" != "$expected_digest" ]]; then
    printf 'input digest changed: %s\n' "$(repo_relative "$artifact_stamp")"
    return 0
  fi

  return 1
}

artifact_is_stale() {
  stale_reason >/dev/null
}

print_status() {
  local reason_file
  local reason

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-status.XXXXXX")"
  tmp_paths+=("$reason_file")

  if stale_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [stale] $skill -> $artifact: $reason"
  else
    dotfiles_agent_update_log "  [ok] $skill -> $artifact"
  fi
}

render_prompt() {
  check_inputs
  ensure_output_dirs

  local harness_notes_ref
  local model_notes_ref
  if [[ -f "$harness_notes" ]]; then
    harness_notes_ref="$(repo_relative "$harness_notes")"
  else
    harness_notes_ref="none (no skill-specific notes for this harness)"
  fi

  if [[ -f "$model_notes" ]]; then
    model_notes_ref="$(repo_relative "$model_notes")"
  else
    model_notes_ref="none (no skill-specific notes for this target)"
  fi

  sed \
    -e "s|{{SKILL_NAME}}|$(sed_replacement "$skill")|g" \
    -e "s|{{ARTIFACT_NAME}}|$(sed_replacement "$artifact")|g" \
    -e "s|{{SOURCE_SKILL}}|$(sed_replacement "$(repo_relative "$source_skill")")|g" \
    -e "s|{{ARTIFACT_DIR}}|$(sed_replacement "$(repo_relative "$artifact_dir")")|g" \
    -e "s|{{HARNESS_GUIDE}}|$(sed_replacement "$(repo_relative "$harness_guide")")|g" \
    -e "s|{{HARNESS_NOTES}}|$(sed_replacement "$harness_notes_ref")|g" \
    -e "s|{{MODEL_GUIDE}}|$(sed_replacement "$(repo_relative "$model_guide")")|g" \
    -e "s|{{MODEL_NOTES}}|$(sed_replacement "$model_notes_ref")|g" \
    -e "s|{{EVAL_DIR}}|$(sed_replacement "$(repo_relative "$eval_dir")")|g" \
    "$template"
}

artifact_skip_reason() {
  check_inputs
  dotfiles_agent_update_harness_skip_reason "$repo_root" "$harness"
}

select_runner_harness() {
  dotfiles_agent_update_select_runner_harness "$repo_root" "$harness"
}

run_harness() {
  local reason
  local reason_file
  local runner_arg
  local runner_args=()
  local runner_command
  local runner_harness
  local output_file
  local prompt_file
  local status

  ensure_skill_prompt_current

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-skip.XXXXXX")"
  tmp_paths+=("$reason_file")
  if artifact_skip_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [skip] $skill -> $artifact: $reason"
    return 0
  fi

  runner_harness="$(select_runner_harness)"
  runner_command="$(dotfiles_agent_harness_command "$repo_root" "$runner_harness")" \
    || die "unknown runner harness: $runner_harness"
  command -v "$runner_command" >/dev/null 2>&1 \
    || die "$runner_command command not found"
  while IFS= read -r runner_arg; do
    runner_args+=("$runner_arg")
  done < <(dotfiles_agent_update_runner_args "$repo_root" "$runner_harness")
  ((${#runner_args[@]} > 0)) \
    || die "no runner_args configured for harness: $runner_harness"

  prompt_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-prompt.XXXXXX")"
  tmp_paths+=("$prompt_file")
  output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-run.XXXXXX")"
  tmp_paths+=("$output_file")

  render_prompt >"$prompt_file"
  dotfiles_agent_update_verbose_log "    runner: $runner_command ($runner_harness)"

  set +e
  "$runner_command" "${runner_args[@]}" <"$prompt_file" >"$output_file" 2>&1
  status=$?
  set -e

  if ((status != 0)); then
    dotfiles_agent_update_print_file "$output_file"
    die "native harness run failed for $skill -> $artifact"
  fi

  if dotfiles_agent_update_is_verbose; then
    dotfiles_agent_update_print_file "$output_file" '    '
  fi

  check_outputs
  write_stamp
  dotfiles_agent_update_log "  [done] $skill -> $artifact"
}

run_target_if_stale() {
  local force_run=${1:-0}
  local reason
  local reason_file

  ensure_skill_prompt_current

  # Skipped native harnesses are intentionally non-updates so aggregate runs can
  # converge on machines that do not have every harness installed.
  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-skill-skip.XXXXXX")"
  tmp_paths+=("$reason_file")
  if artifact_skip_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [skip] $skill -> $artifact: $reason"
    return 1
  fi

  if ((force_run == 1)); then
    dotfiles_agent_update_log "  [force] $skill -> $artifact"
    run_harness
    return 0
  fi

  if artifact_is_stale; then
    print_status
    run_harness
    return 0
  fi

  print_status
  return 1
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

single_artifact_or_die() {
  local selected=$1
  local count=0
  local one=''
  local selected_artifact

  while IFS= read -r selected_artifact; do
    [[ -n "$selected_artifact" ]] || continue
    one=$selected_artifact
    count=$((count + 1))
  done <<<"$selected"

  [[ "$count" -eq 1 ]] \
    || die "--action $action requires exactly one harness/model target; selected $count"

  printf '%s\n' "$one"
}

run_action_once() {
  local selected=$1
  local selected_artifact

  while IFS= read -r selected_artifact; do
    [[ -n "$selected_artifact" ]] || continue
    configure_artifact "$requested_skill" "$selected_artifact"

    case "$action" in
      check)
        check_inputs
        dotfiles_agent_update_log "[ok] $skill -> $artifact"
        ;;
      status)
        print_status
        ;;
      run)
        run_harness
        ;;
      record-stamp)
        check_inputs
        check_outputs
        write_stamp
        dotfiles_agent_update_log "[stamp] $skill -> $artifact ($(repo_relative "$artifact_stamp"))"
        ;;
      *)
        die "internal error: unsupported multi-target action: $action"
        ;;
    esac
  done <<<"$selected"
}

run_stale_targets_to_fixed_point() {
  local force_pass
  local pass=1
  local selected
  local selected_artifact
  local updated

  dotfiles_agent_update_log "Updating skill: $requested_skill"
  while ((pass <= max_passes)); do
    dotfiles_agent_update_log "Pass $pass"
    selected="$(selected_artifacts_or_die)"
    force_pass=0
    if ((force_update == 1 && pass == 1)); then
      force_pass=1
    fi
    updated=0

    while IFS= read -r selected_artifact; do
      [[ -n "$selected_artifact" ]] || continue
      configure_artifact "$requested_skill" "$selected_artifact"
      if run_target_if_stale "$force_pass"; then
        updated=1
      fi
    done <<<"$selected"

    if ((updated == 0)); then
      dotfiles_agent_update_log "Done: fixed point reached after $pass pass(es)."
      return 0
    fi

    pass=$((pass + 1))
  done

  die "did not reach a fixed point after $max_passes pass(es)"
}

action=run-if-stale
force_update=0
max_passes=5
verbose=0
skill=''
requested_skill=''
target_harness=''
target_model=''

while (($# > 0)); do
  case "$1" in
    --action)
      shift
      (($# > 0)) || die 'missing value for --action'
      action=$1
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
    --max-passes)
      shift
      (($# > 0)) || die 'missing value for --max-passes'
      max_passes=$1
      ;;
    --force)
      force_update=1
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
      [[ -z "$requested_skill" ]] || die "unexpected argument: $1"
      requested_skill=$1
      ;;
  esac
  shift
done

[[ -n "$requested_skill" ]] || {
  usage >&2
  exit 2
}

validate_positive_integer '--max-passes' "$max_passes"
validate_target_filters
if ((verbose == 1)); then
  export DOTFILES_AGENT_VERBOSE=1
fi
if ((force_update == 1)) && [[ "$action" != run-if-stale ]]; then
  die '--force only applies to --action run-if-stale; use --action run to run once unconditionally'
fi
selected_artifacts="$(selected_artifacts_or_die)"

case "$action" in
  check | status | run | record-stamp)
    run_action_once "$selected_artifacts"
    ;;
  is-stale)
    single_artifact="$(single_artifact_or_die "$selected_artifacts")"
    configure_artifact "$requested_skill" "$single_artifact"
    artifact_is_stale
    ;;
  print-prompt)
    single_artifact="$(single_artifact_or_die "$selected_artifacts")"
    configure_artifact "$requested_skill" "$single_artifact"
    render_prompt
    ;;
  should-skip)
    single_artifact="$(single_artifact_or_die "$selected_artifacts")"
    configure_artifact "$requested_skill" "$single_artifact"
    artifact_skip_reason
    ;;
  run-if-stale)
    run_stale_targets_to_fixed_point
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
