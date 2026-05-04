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
    '  agents/scripts/update-prompt.bash [options] <prompt>' \
    '' \
    'Updates one source prompt across selected harness prompt artifacts.' \
    '<prompt> may be a globally unique prompt directory name or a path relative to agents/prompts/src/.' \
    '' \
    'Options:' \
    '  --harness HARNESS    Limit to one harness; creates the prompt artifact if missing.' \
    '  --action ACTION      check, status, is-stale, print-prompt, run, run-if-stale, record-stamp, should-skip.' \
    '  --force              Re-run selected targets during the first run-if-stale pass.' \
    '  --max-passes N      Maximum fixed-point passes for run-if-stale (default: 5).' \
    '  --verbose           Show successful native harness output.' \
    '' \
    'Defaults:' \
    '  ACTION defaults to run-if-stale.' \
    '  With no --harness, existing harness directories under agents/prompts/harnesses/ are selected.'
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

resolve_source_prompt() {
  dotfiles_agent_update_resolve_source "$repo_root" agents/prompts/src PROMPT.md 'source prompt' "$1"
}

require_unique_source_prompt_id() {
  dotfiles_agent_update_require_unique_source_id "$repo_root" agents/prompts/src PROMPT.md 'source prompt' "$1"
}

configure_prompt() {
  requested_prompt=$1
  prompt_source_relpath="$(resolve_source_prompt "$requested_prompt")"
  prompt="$(dotfiles_agent_source_prompt_id "$prompt_source_relpath")"
  dotfiles_agent_target_id_is_valid "$prompt" \
    || die "invalid source prompt directory name: $prompt (use only letters, numbers, dots, underscores, and hyphens)"
  require_unique_source_prompt_id "$prompt"
  prompt_dir="$repo_root/agents/prompts/src/$prompt_source_relpath"
  source_prompt="$prompt_dir/PROMPT.md"
  harness_notes="$prompt_dir/harness-notes/${harness}.md"

  require_dir "$prompt_dir"
  require_file "$source_prompt"
}

configure_prompt_artifact() {
  local requested_prompt=$1
  local requested_harness=$2

  harness=$requested_harness
  configure_prompt "$requested_prompt"

  harness_config="$repo_root/agents/harnesses/${harness}.yaml"
  harness_guide="$repo_root/agents/harnesses/${harness}.md"
  prompt_artifact_dir="$repo_root/agents/prompts/harnesses/$harness"
  prompt_artifact="$prompt_artifact_dir/$prompt.md"
  prompt_stamp_dir="$repo_root/agents/prompts/.update-stamps/$harness/$prompt"
  prompt_stamp="$prompt_stamp_dir/inputs.sha256"
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

prompt_updater_template() {
  local runner_harness=${1:-$harness}
  local template="$repo_root/agents/prompts/harnesses/$runner_harness/update-prompt-artifact.md"

  if [[ -f "$template" ]]; then
    printf '%s\n' "$template"
    return 0
  fi

  printf '%s\n' "$repo_root/agents/prompts/src/update-prompt-artifact/PROMPT.md"
}

check_inputs() {
  require_file "$source_prompt"
  require_supported_harness
  require_file "$harness_guide"
  require_file "$(prompt_updater_template "$harness")"
}

ensure_output_dirs() {
  mkdir -p "$prompt_artifact_dir"
}

check_outputs() {
  require_file "$prompt_artifact"
}

input_files() {
  printf '%s\n' \
    "$source_prompt" \
    "$harness_config" \
    "$harness_guide" \
    "$(prompt_updater_template "$harness")"

  if [[ -f "$harness_notes" ]]; then
    printf '%s\n' "$harness_notes"
  fi
}

compute_input_digest() {
  input_files | dotfiles_agent_update_compute_digest "$repo_root" 'dotfiles-prompt-artifact-inputs-v1'
}

write_stamp() {
  mkdir -p "$prompt_stamp_dir"
  compute_input_digest >"$prompt_stamp"
}

stale_reason() {
  check_inputs

  if [[ ! -f "$prompt_artifact" ]]; then
    printf 'missing output: %s\n' "$(repo_relative "$prompt_artifact")"
    return 0
  fi

  if [[ ! -f "$prompt_stamp" ]]; then
    printf 'missing input digest stamp: %s\n' "$(repo_relative "$prompt_stamp")"
    return 0
  fi

  local expected_digest
  local actual_digest
  expected_digest="$(compute_input_digest)"
  actual_digest="$(<"$prompt_stamp")"

  if [[ "$actual_digest" != "$expected_digest" ]]; then
    printf 'input digest changed: %s\n' "$(repo_relative "$prompt_stamp")"
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

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt-status.XXXXXX")"
  tmp_paths+=("$reason_file")

  if stale_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [stale] prompt $prompt -> $harness: $reason"
  else
    dotfiles_agent_update_log "  [ok] prompt $prompt -> $harness"
  fi
}

render_prompt() {
  local runner_harness=${1:-$harness}
  local template
  local harness_notes_ref

  check_inputs
  ensure_output_dirs
  template="$(prompt_updater_template "$runner_harness")"

  if [[ -f "$harness_notes" ]]; then
    harness_notes_ref="$(repo_relative "$harness_notes")"
  else
    harness_notes_ref="none (no harness-specific notes for this prompt)"
  fi

  sed \
    -e "s|{{PROMPT_NAME}}|$(sed_replacement "$prompt")|g" \
    -e "s|{{SOURCE_PROMPT}}|$(sed_replacement "$(repo_relative "$source_prompt")")|g" \
    -e "s|{{PROMPT_ARTIFACT}}|$(sed_replacement "$(repo_relative "$prompt_artifact")")|g" \
    -e "s|{{HARNESS_GUIDE}}|$(sed_replacement "$(repo_relative "$harness_guide")")|g" \
    -e "s|{{HARNESS_NOTES}}|$(sed_replacement "$harness_notes_ref")|g" \
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

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt-skip.XXXXXX")"
  tmp_paths+=("$reason_file")
  if artifact_skip_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [skip] prompt $prompt -> $harness: $reason"
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

  prompt_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt.XXXXXX")"
  tmp_paths+=("$prompt_file")
  output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt-run.XXXXXX")"
  tmp_paths+=("$output_file")

  render_prompt "$runner_harness" >"$prompt_file"
  dotfiles_agent_update_verbose_log "    runner: $runner_command ($runner_harness)"

  set +e
  "$runner_command" "${runner_args[@]}" <"$prompt_file" >"$output_file" 2>&1
  status=$?
  set -e

  if ((status != 0)); then
    dotfiles_agent_update_print_file "$output_file"
    die "native harness run failed for prompt $prompt -> $harness"
  fi

  if dotfiles_agent_update_is_verbose; then
    dotfiles_agent_update_print_file "$output_file" '    '
  fi

  check_outputs
  write_stamp
  dotfiles_agent_update_log "  [done] prompt $prompt -> $harness"
}

run_target_if_stale() {
  local force_run=${1:-0}
  local reason
  local reason_file

  reason_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-prompt-skip.XXXXXX")"
  tmp_paths+=("$reason_file")
  if artifact_skip_reason >"$reason_file"; then
    reason="$(<"$reason_file")"
    dotfiles_agent_update_log "  [skip] prompt $prompt -> $harness: $reason"
    return 1
  fi

  if ((force_run == 1)); then
    dotfiles_agent_update_log "  [force] prompt $prompt -> $harness"
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

selected_harnesses_or_die() {
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

single_harness_or_die() {
  local selected=$1
  local count=0
  local one=''
  local selected_harness

  while IFS= read -r selected_harness; do
    [[ -n "$selected_harness" ]] || continue
    one=$selected_harness
    count=$((count + 1))
  done <<<"$selected"

  [[ "$count" -eq 1 ]] \
    || die "--action $action requires exactly one harness target; selected $count"

  printf '%s\n' "$one"
}

run_action_once() {
  local selected=$1
  local selected_harness

  while IFS= read -r selected_harness; do
    [[ -n "$selected_harness" ]] || continue
    configure_prompt_artifact "$requested_prompt" "$selected_harness"

    case "$action" in
      check)
        check_inputs
        dotfiles_agent_update_log "[ok] prompt $prompt -> $harness"
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
        dotfiles_agent_update_log "[stamp] prompt $prompt -> $harness ($(repo_relative "$prompt_stamp"))"
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
  local selected_harness
  local updated

  dotfiles_agent_update_log "Updating prompt: $requested_prompt"
  while ((pass <= max_passes)); do
    dotfiles_agent_update_log "Pass $pass"
    selected="$(selected_harnesses_or_die)"
    force_pass=0
    if ((force_update == 1 && pass == 1)); then
      force_pass=1
    fi
    updated=0

    while IFS= read -r selected_harness; do
      [[ -n "$selected_harness" ]] || continue
      configure_prompt_artifact "$requested_prompt" "$selected_harness"
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
prompt=''
requested_prompt=''
target_harness=''

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
    --force)
      force_update=1
      ;;
    --verbose)
      verbose=1
      ;;
    --max-passes)
      shift
      (($# > 0)) || die 'missing value for --max-passes'
      max_passes=$1
      ;;
    -h | --help | help)
      usage
      exit 0
      ;;
    --*)
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$requested_prompt" ]] || die "unexpected extra argument: $1"
      requested_prompt=$1
      ;;
  esac
  shift
done

[[ -n "$requested_prompt" ]] || {
  usage >&2
  exit 2
}

validate_positive_integer '--max-passes' "$max_passes"
validate_target_filters
if ((verbose == 1)); then
  export DOTFILES_AGENT_VERBOSE=1
fi

case "$action" in
  check | status | run | record-stamp | run-if-stale | is-stale | print-prompt | should-skip) ;;
  *)
    die "unsupported action: $action"
    ;;
esac

if ((force_update == 1)) && [[ "$action" != run-if-stale ]]; then
  die '--force only applies to --action run-if-stale; use --action run to run once unconditionally'
fi

selected_harnesses="$(selected_harnesses_or_die)"

case "$action" in
  check | status | run | record-stamp)
    run_action_once "$selected_harnesses"
    ;;
  run-if-stale)
    run_stale_targets_to_fixed_point
    ;;
  is-stale)
    selected_harness="$(single_harness_or_die "$selected_harnesses")"
    configure_prompt_artifact "$requested_prompt" "$selected_harness"
    if artifact_is_stale; then
      exit 0
    fi
    exit 1
    ;;
  should-skip)
    selected_harness="$(single_harness_or_die "$selected_harnesses")"
    configure_prompt_artifact "$requested_prompt" "$selected_harness"
    if artifact_skip_reason; then
      exit 0
    fi
    exit 1
    ;;
  print-prompt)
    selected_harness="$(single_harness_or_die "$selected_harnesses")"
    configure_prompt_artifact "$requested_prompt" "$selected_harness"
    render_prompt
    ;;
esac
