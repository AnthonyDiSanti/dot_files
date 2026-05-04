#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_root="$repo_root/test/fixtures/verify"
tmp_root="$(mktemp -d)"
tmp_paths=("$tmp_root")

source "$repo_root/scripts/home_tree_manifest.sh"
source "$repo_root/scripts/shell_files.bash"
source "$repo_root/agents/scripts/lib/agent-harnesses.bash"

cleanup() {
  local path

  if ((${#tmp_paths[@]} == 0)); then
    return 0
  fi

  for path in "${tmp_paths[@]}"; do
    rm -rf "$path"
  done
}

trap cleanup EXIT

log_suite() {
  printf '==> %s\n' "$1"
}

log_success() {
  printf '==> all checks passed (total: %s)\n' "$1"
}

log_check() {
  printf '  - %s' "$1"
}

format_duration() {
  local seconds="$1"

  awk -v seconds="$seconds" '
    BEGIN {
      if (seconds < 1) {
        milliseconds = int((seconds * 1000) + 0.5)
        if (milliseconds < 1) {
          print "<1ms"
        } else {
          printf "%dms\n", milliseconds
        }
      } else if (seconds < 10) {
        printf "%.2fs\n", seconds
      } else {
        printf "%.1fs\n", seconds
      }
    }
  '
}

run_timed_check() {
  local check_name="$1"
  local elapsed_file
  local elapsed_seconds
  local output_file
  local status
  local TIMEFORMAT="%3R"

  shift
  elapsed_file="$(make_temp_file)"
  output_file="$(make_temp_file)"

  log_check "$check_name"

  # Keep passing checks compact; replay captured output only when debugging a failure.
  set +e
  { time {
    (
      set -euo pipefail
      "$@"
    ) >"$output_file" 2>&1
  }; } 2>"$elapsed_file"
  status=$?
  set -e

  elapsed_seconds="$(<"$elapsed_file")"
  if ((status == 0)); then
    printf ' (%s)\n' "$(format_duration "$elapsed_seconds")"
  else
    printf ' (failed after %s)\n' "$(format_duration "$elapsed_seconds")"
  fi

  if ((status != 0)) && [[ -s "$output_file" ]]; then
    cat "$output_file"
  fi

  return "$status"
}

fail() {
  echo "verify: $*" >&2
  exit 1
}

require_command() {
  dotfiles_have_command "$1" || fail "$1 is required"
}

make_temp_file() {
  local path
  path="$(mktemp "$tmp_root/file.XXXXXX")"
  printf '%s\n' "$path"
}

make_temp_dir() {
  local path
  path="$(mktemp -d "$tmp_root/dir.XXXXXX")"
  printf '%s\n' "$path"
}

assert_directory() {
  local path="$1"

  [[ -d "$path" ]] || fail "$path is not a directory"
  [[ ! -L "$path" ]] || fail "$path should be a real directory, not a symlink"
}

assert_symlink() {
  local path="$1"
  local expected="$2"
  local actual

  [[ -L "$path" ]] || fail "$path is not a symlink"
  actual="$(readlink "$path")"
  [[ "$actual" == "$expected" ]] || fail "$path points to $actual, expected $expected"
}

check_shell_syntax() {
  local script_path

  while IFS= read -r -d '' script_path; do
    check_shell_file_syntax "$script_path"
  done < <(dotfiles_emit_tracked_shell_files "$repo_root")
}

check_shell_file_syntax() {
  local script_path="$1"
  local rel_path
  local shell

  [[ -f "$script_path" ]] || return 0

  rel_path="$(dotfiles_shell_file_rel_path "$repo_root" "$script_path")"
  shell="$(dotfiles_shell_file_dialect "$script_path" "$rel_path")" || return 0

  case "$shell" in
    bash)
      bash -n "$script_path"
      ;;
    zsh)
      zsh -n "$script_path"
      ;;
    sh)
      sh -n "$script_path"
      ;;
  esac

  # This helper is intentionally POSIX-shaped but sourced by zsh for Git's zsh wrapper.
  if [[ ${script_path#"$repo_root/"} == home/.config/bash/git-completion.sh ]]; then
    bash -n "$script_path"
    zsh -n "$script_path"
  fi
}

check_shell_lint() {
  "$repo_root/scripts/shellcheck-dotfiles.bash" --all
}

check_shell_format() {
  "$repo_root/scripts/shfmt-dotfiles.bash" --all --check
}

check_submodule_file_enumeration() {
  local emitted_file
  local rel_path
  local submodule_path
  local submodule_paths

  submodule_paths="$(dotfiles_emit_git_submodule_paths "$repo_root")"
  [[ -n "$submodule_paths" ]] || return 0

  while IFS= read -r submodule_path; do
    [[ -n "$submodule_path" ]] || continue
    dotfiles_path_is_in_git_submodule "$repo_root" "$submodule_path" \
      || fail "submodule path should be recognized: $submodule_path"
    dotfiles_path_is_in_git_submodule "$repo_root" "$submodule_path/test-script.sh" \
      || fail "path below submodule should be recognized: $submodule_path/test-script.sh"
  done <<<"$submodule_paths"

  while IFS= read -r -d '' emitted_file; do
    rel_path="$(dotfiles_shell_file_rel_path "$repo_root" "$emitted_file")"
    while IFS= read -r submodule_path; do
      [[ -n "$submodule_path" ]] || continue
      case "$rel_path" in
        "$submodule_path" | "$submodule_path"/*)
          fail "shell-file enumeration should exclude submodule path: $rel_path"
          ;;
      esac
    done <<<"$submodule_paths"
  done < <(dotfiles_emit_tracked_shell_files "$repo_root")
}

check_dev_tool_wrappers() {
  # VS Code probes ShellCheck with -V and may not use the workspace as cwd.
  (cd / && "$repo_root/scripts/shellcheck-dotfiles.bash" -V >/dev/null)
}

check_tmux_config() {
  local aggressive_resize
  local control_aggressive_resize
  local control_focus_events
  local control_tmux_config_output
  local bell_action
  local focus_events
  local monitor_bell
  local socket_name
  local socket_name_control
  local status
  local tmux_config_output

  dotfiles_have_command tmux || return 0

  socket_name="dotfiles-verify-${BASHPID:-$$}"

  set +e
  tmux_config_output="$(
    tmux -L "$socket_name" -f /dev/null \
      new-session -d -s dotfiles-verify 'sleep 60' \; \
      source-file "$repo_root/home/.tmux.conf" \; \
      show-window-options -gv aggressive-resize \; \
      show-options -gv focus-events \; \
      show-options -gv bell-action \; \
      show-window-options -gv monitor-bell 2>&1
  )"
  status=$?
  tmux -L "$socket_name" kill-server >/dev/null 2>&1 || true
  set -e

  if ((status != 0)); then
    printf '%s\n' "$tmux_config_output"
    fail "tmux config failed to load"
  fi

  aggressive_resize="$(sed -n '1p' <<<"$tmux_config_output")"
  focus_events="$(sed -n '2p' <<<"$tmux_config_output")"
  bell_action="$(sed -n '3p' <<<"$tmux_config_output")"
  monitor_bell="$(sed -n '4p' <<<"$tmux_config_output")"

  [[ "$aggressive_resize" == on ]] \
    || fail "tmux normal startup aggressive-resize should be on, got ${aggressive_resize:-<empty>}"
  [[ "$focus_events" == on ]] \
    || fail "tmux normal startup focus-events should be on, got ${focus_events:-<empty>}"
  [[ "$bell_action" == any ]] \
    || fail "tmux bell-action should be any, got ${bell_action:-<empty>}"
  [[ "$monitor_bell" == on ]] \
    || fail "tmux monitor-bell should be on, got ${monitor_bell:-<empty>}"

  socket_name_control="dotfiles-verify-cc-${BASHPID:-$$}"

  set +e
  control_tmux_config_output="$(
    DOTFILES_TMUX_CONTROL_MODE=1 \
      tmux -L "$socket_name_control" -f "$repo_root/home/.tmux.conf" \
      new-session -d -s dotfiles-verify-cc 'sleep 60' \; \
      show-window-options -gv aggressive-resize \; \
      show-options -gv focus-events 2>&1
  )"
  status=$?
  tmux -L "$socket_name_control" kill-server >/dev/null 2>&1 || true
  set -e

  if ((status != 0)); then
    printf '%s\n' "$control_tmux_config_output"
    fail "tmux control-mode config failed to load"
  fi

  control_aggressive_resize="$(sed -n '1p' <<<"$control_tmux_config_output")"
  control_focus_events="$(sed -n '2p' <<<"$control_tmux_config_output")"

  [[ "$control_aggressive_resize" == off ]] \
    || fail "tmux control-mode startup aggressive-resize should be off, got ${control_aggressive_resize:-<empty>}"
  [[ "$control_focus_events" == off ]] \
    || fail "tmux control-mode startup focus-events should be off, got ${control_focus_events:-<empty>}"
}

check_tmux_control_mode_options() {
  local actual
  local expected
  local fixture_path

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  fixture_path="$fixture_root/fake-tmux:${PATH:-}"

  env \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$actual" \
    DOTFILES_FAKE_TMUX_CLIENT_CONTROL_MODES='0\n' \
    "$repo_root/home/.local/bin/dotfiles-tmux-control-mode-options"
  printf '%s\n' \
    'set-option -g focus-events on' \
    'set-window-option -g aggressive-resize on' >"$expected"
  diff -u "$expected" "$actual"

  : >"$actual"
  env \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$actual" \
    DOTFILES_FAKE_TMUX_CLIENT_CONTROL_MODES='0\n1\n' \
    "$repo_root/home/.local/bin/dotfiles-tmux-control-mode-options"
  printf '%s\n' \
    'set-option -g focus-events off' \
    'set-window-option -g aggressive-resize off' >"$expected"
  diff -u "$expected" "$actual"
}

check_clipboard_wrapper() {
  local actual
  local expected
  local fake_clipboard
  local fixture_path
  local payload

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  fake_clipboard="$(make_temp_file)"
  fixture_path="$fixture_root/fake-wsl-clipboard:${PATH:-}"
  payload="$(make_temp_file)"

  env \
    PATH="$fixture_path" \
    WSL_DISTRO_NAME=Ubuntu \
    DOTFILES_FAKE_WINDOWS_CLIPBOARD_FILE="$fake_clipboard" \
    "$repo_root/home/.local/bin/dotfiles-clipboard" status >"$actual"
  printf '%s\n' wsl >"$expected"
  diff -u "$expected" "$actual"

  printf 'alpha\nbeta' >"$payload"
  env \
    PATH="$fixture_path" \
    WSL_DISTRO_NAME=Ubuntu \
    DOTFILES_FAKE_WINDOWS_CLIPBOARD_FILE="$fake_clipboard" \
    "$repo_root/home/.local/bin/dotfiles-clipboard" copy <"$payload"
  cmp "$payload" "$fake_clipboard"

  printf 'alpha\r\nbeta' >"$fake_clipboard"
  env \
    PATH="$fixture_path" \
    WSL_DISTRO_NAME=Ubuntu \
    DOTFILES_FAKE_WINDOWS_CLIPBOARD_FILE="$fake_clipboard" \
    "$repo_root/home/.local/bin/dotfiles-clipboard" paste >"$actual"
  printf 'alpha\nbeta' >"$expected"
  cmp "$expected" "$actual"
}

check_agent_skill_source_discovery() {
  local actual
  local expected
  local status
  local tmp_repo

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  tmp_repo="$(make_temp_dir)"

  mkdir -p \
    "$tmp_repo/agents/skills/src/team/shell/example-skill" \
    "$tmp_repo/agents/skills/src/other/second-skill" \
    "$tmp_repo/agents/skills/src/other/duplicate-skill" \
    "$tmp_repo/agents/skills/src/team/duplicate-skill" \
    "$tmp_repo/agents/prompts/src/team/update-example" \
    "$tmp_repo/agents/prompts/src/other/duplicate-prompt" \
    "$tmp_repo/agents/prompts/src/team/duplicate-prompt" \
    "$tmp_repo/agents/skills/artifacts/codex/gpt-5.5" \
    "$tmp_repo/agents/prompts/harnesses/codex"
  : >"$tmp_repo/agents/skills/src/team/shell/example-skill/SKILL.md"
  : >"$tmp_repo/agents/skills/src/other/second-skill/SKILL.md"
  : >"$tmp_repo/agents/skills/src/other/duplicate-skill/SKILL.md"
  : >"$tmp_repo/agents/skills/src/team/duplicate-skill/SKILL.md"
  : >"$tmp_repo/agents/prompts/src/team/update-example/PROMPT.md"
  : >"$tmp_repo/agents/prompts/src/other/duplicate-prompt/PROMPT.md"
  : >"$tmp_repo/agents/prompts/src/team/duplicate-prompt/PROMPT.md"
  cp -R "$repo_root/agents/scripts" "$tmp_repo/agents/scripts"

  dotfiles_agent_source_skill_dirs "$tmp_repo" >"$actual"
  printf '%s\n' \
    'other/duplicate-skill' \
    'other/second-skill' \
    'team/duplicate-skill' \
    'team/shell/example-skill' >"$expected"
  diff -u "$expected" "$actual"

  dotfiles_agent_source_skill_matches "$tmp_repo" example-skill >"$actual"
  printf '%s\n' 'team/shell/example-skill' >"$expected"
  diff -u "$expected" "$actual"

  dotfiles_agent_source_prompt_dirs "$tmp_repo" >"$actual"
  printf '%s\n' \
    'other/duplicate-prompt' \
    'team/duplicate-prompt' \
    'team/update-example' >"$expected"
  diff -u "$expected" "$actual"

  dotfiles_agent_source_prompt_matches "$tmp_repo" update-example >"$actual"
  printf '%s\n' 'team/update-example' >"$expected"
  diff -u "$expected" "$actual"

  [[ "$(dotfiles_agent_source_prompt_id team/update-example)" == update-example ]] \
    || fail "nested source prompt id should come from the prompt directory name"

  [[ "$(dotfiles_agent_source_skill_id team/shell/example-skill)" == example-skill ]] \
    || fail "nested source skill id should come from the skill directory name"

  set +e
  "$tmp_repo/agents/scripts/update-skill.bash" --action status duplicate-skill >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "duplicate skill directory lookup should fail with status 2, got $status"
  printf '%s\n' \
    'update-skill.bash: source skill directory name conflict: duplicate-skill matches multiple src paths (other/duplicate-skill team/duplicate-skill); every source skill directory name must be globally unique because runtime artifacts use it as the id' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$tmp_repo/agents/scripts/update-skill.bash" --action status team/duplicate-skill >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "explicit duplicate source path should fail with status 2, got $status"
  printf '%s\n' \
    'update-skill.bash: source skill directory name conflict: duplicate-skill is used by multiple src paths (other/duplicate-skill team/duplicate-skill); every source skill directory name must be globally unique because runtime artifacts use it as the id' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$tmp_repo/agents/scripts/update-prompt.bash" --action status duplicate-prompt >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "duplicate prompt directory lookup should fail with status 2, got $status"
  printf '%s\n' \
    'update-prompt.bash: source prompt directory name conflict: duplicate-prompt matches multiple src paths (other/duplicate-prompt team/duplicate-prompt); every source prompt directory name must be globally unique because runtime artifacts use it as the id' >"$expected"
  diff -u "$expected" "$actual"
}

check_agent_update_script_options() {
  local actual
  local artifact
  local artifact_harness
  local artifact_model
  local expected
  local harness_notes_rel
  local prompt
  local prompt_harness
  local prompt_harness_notes_rel
  local prompt_source_relpath
  local skill
  local skill_source_relpath
  local status

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  artifact="$(first_agent_skill_artifact)" \
    || fail 'no agent skill artifacts found for update script option verification'
  skill="$(first_agent_skill_for_artifact "$artifact")" \
    || fail "artifact should contain at least one skill: $artifact"
  artifact_harness="$(dotfiles_agent_artifact_harness "$artifact")" \
    || fail "artifact should include a harness: $artifact"
  artifact_model="$(dotfiles_agent_artifact_model "$artifact" "$artifact_harness")" \
    || fail "artifact should include a model: $artifact"
  skill_source_relpath="$(dotfiles_agent_source_skill_matches "$repo_root" "$skill" | sed -n '1p')"
  [[ -n "$skill_source_relpath" ]] \
    || fail "artifact skill should have a source skill: $skill"
  harness_notes_rel="agents/skills/src/$skill_source_relpath/harness-notes/$artifact_harness.md"
  prompt_harness="$(first_agent_prompt_harness)" \
    || fail 'no agent prompt harnesses found for update script option verification'
  prompt="$(first_agent_prompt_for_harness "$prompt_harness")" \
    || fail "prompt harness should contain at least one prompt artifact: $prompt_harness"
  prompt_source_relpath="$(dotfiles_agent_source_prompt_matches "$repo_root" "$prompt" | sed -n '1p')"
  [[ -n "$prompt_source_relpath" ]] \
    || fail "prompt artifact should have a source prompt: $prompt"
  prompt_harness_notes_rel="agents/prompts/src/$prompt_source_relpath/harness-notes/$prompt_harness.md"

  "$repo_root/agents/scripts/update-skill.bash" --help >"$actual"
  grep -q -- '--force' "$actual" \
    || fail 'update-skill.bash help should document --force'
  grep -q -- '--verbose' "$actual" \
    || fail 'update-skill.bash help should document --verbose'

  "$repo_root/agents/scripts/update-all.bash" --help >"$actual"
  grep -q -- '--force' "$actual" \
    || fail 'update-all.bash help should document --force'
  grep -q -- '--verbose' "$actual" \
    || fail 'update-all.bash help should document --verbose'
  grep -q -- '--type TYPE' "$actual" \
    || fail 'update-all.bash help should document --type'
  grep -q -- '--prompt PROMPT' "$actual" \
    || fail 'update-all.bash help should document --prompt'

  "$repo_root/agents/scripts/update-prompt.bash" --help >"$actual"
  grep -q -- '--force' "$actual" \
    || fail 'update-prompt.bash help should document --force'
  grep -q -- '--verbose' "$actual" \
    || fail 'update-prompt.bash help should document --verbose'

  "$repo_root/agents/scripts/update-skill.bash" \
    --harness "$artifact_harness" \
    --model "$artifact_model" \
    --action status \
    "$skill" >"$actual"
  grep -Eq '^  \[(ok|stale)\] .+ -> .+' "$actual" \
    || fail 'update-skill.bash status should use concise bracketed output'

  "$repo_root/agents/scripts/update-prompt.bash" \
    --harness "$prompt_harness" \
    --action status \
    "$prompt" >"$actual"
  grep -Eq '^  \[(ok|stale)\] prompt .+ -> .+' "$actual" \
    || fail 'update-prompt.bash status should use concise bracketed output'

  if [[ -f "$repo_root/$harness_notes_rel" ]]; then
    "$repo_root/agents/scripts/update-skill.bash" \
      --harness "$artifact_harness" \
      --model "$artifact_model" \
      --action print-prompt \
      "$skill" >"$actual"
    grep -F -q -- "$harness_notes_rel" "$actual" \
      || fail "update-skill.bash prompt should include harness notes: $harness_notes_rel"
  fi

  if [[ -f "$repo_root/$prompt_harness_notes_rel" ]]; then
    "$repo_root/agents/scripts/update-prompt.bash" \
      --harness "$prompt_harness" \
      --action print-prompt \
      "$prompt" >"$actual"
    grep -F -q -- "$prompt_harness_notes_rel" "$actual" \
      || fail "update-prompt.bash prompt should include harness notes: $prompt_harness_notes_rel"
  fi

  set +e
  "$repo_root/agents/scripts/update-skill.bash" \
    --force \
    --action status \
    "$skill" >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "update-skill.bash --force with status should fail with status 2, got $status"
  printf '%s\n' \
    'update-skill.bash: --force only applies to --action run-if-stale; use --action run to run once unconditionally' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$repo_root/agents/scripts/update-all.bash" --skill "$skill" >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 1 ]] || fail "update-all.bash --skill should fail with status 1, got $status"
  printf '%s\n' \
    'update-all.bash: update-all.bash does not accept --skill; use update-skill.bash <skill> for skill-specific updates' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$repo_root/agents/scripts/update-all.bash" \
    --type skill \
    --prompt update-skill-artifact >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 1 ]] || fail "update-all.bash --type skill --prompt should fail with status 1, got $status"
  printf '%s\n' \
    'update-all.bash: --prompt only applies to prompt updates' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$repo_root/agents/scripts/update-all.bash" \
    --type prompt \
    --model gpt-5.5 >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 1 ]] || fail "update-all.bash --type prompt --model should fail with status 1, got $status"
  printf '%s\n' \
    'update-all.bash: prompt artifacts are harness-scoped; --model only applies to skill updates' >"$expected"
  diff -u "$expected" "$actual"

  dotfiles_agent_harness_runner_args "$repo_root" gemini >"$actual"
  if grep -q 'artifact-update instructions from stdin' "$actual"; then
    fail 'gemini runner_args should keep prompt prose in prompt artifacts, not harness YAML'
  fi
}

check_agent_harness_config_parser() {
  local actual
  local expected
  local tmp_repo

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  tmp_repo="$(make_temp_dir)"

  mkdir -p "$tmp_repo/agents/harnesses"
  {
    printf '%s\n' \
      'home_config: .example/config.toml' \
      'model_config_key: model' \
      'skills_dir: .example/skills' \
      '' \
      'model_aliases:' \
      '  best: example-latest' \
      '  "quoted": "quoted-model"' \
      '' \
      'outputs:' \
      '  - SKILL.md' \
      '  - agents/openai.yaml' \
      '' \
      'runner_args: [exec, --label, "two words", '\''comma,inside'\'', "{{repo_root}}"]'
  } >"$tmp_repo/agents/harnesses/example.yaml"

  dotfiles_agent_harness_outputs "$tmp_repo" example >"$actual"
  printf '%s\n' \
    'SKILL.md' \
    'agents/openai.yaml' >"$expected"
  diff -u "$expected" "$actual"

  dotfiles_agent_harness_runner_args "$tmp_repo" example >"$actual"
  printf '%s\n' \
    'exec' \
    '--label' \
    'two words' \
    'comma,inside' \
    '{{repo_root}}' >"$expected"
  diff -u "$expected" "$actual"

  [[ "$(dotfiles_agent_harness_model_alias "$tmp_repo" example best)" == example-latest ]] \
    || fail 'harness model alias parser should read plain map entries'
  [[ "$(dotfiles_agent_harness_model_alias "$tmp_repo" example quoted)" == quoted-model ]] \
    || fail 'harness model alias parser should read quoted map entries'
  [[ "$(dotfiles_agent_harness_normalize_model "$tmp_repo" example unknown)" == unknown ]] \
    || fail 'harness model normalization should fall back to the original model'
  [[ "$(dotfiles_agent_select_artifacts "$tmp_repo" example best)" == example/example-latest ]] \
    || fail 'explicit harness/model target selection should normalize model aliases'
}

first_agent_skill_for_artifact() {
  local artifact=$1
  local skill_file
  local skills_root="$repo_root/agents/skills/artifacts/$artifact/skills"

  [[ -d "$skills_root" ]] || return 1

  skill_file="$(
    find "$skills_root" \
      -mindepth 2 \
      -maxdepth 2 \
      -type f \
      -name SKILL.md \
      | LC_ALL=C sort \
      | sed -n '1p'
  )"
  [[ -n "$skill_file" ]] || return 1
  skill_file="${skill_file%/SKILL.md}"
  printf '%s\n' "${skill_file##*/}"
}

first_agent_skill_artifact() {
  local artifact

  while IFS= read -r artifact; do
    [[ -n "$artifact" ]] || continue
    first_agent_skill_for_artifact "$artifact" >/dev/null || continue
    printf '%s\n' "$artifact"
    return 0
  done < <(dotfiles_agent_select_artifacts "$repo_root" '' '')

  return 1
}

first_agent_skill_artifact_for_harness() {
  local artifact
  local harness=$1

  while IFS= read -r artifact; do
    [[ -n "$artifact" ]] || continue
    first_agent_skill_for_artifact "$artifact" >/dev/null || continue
    printf '%s\n' "$artifact"
    return 0
  done < <(dotfiles_agent_select_artifacts "$repo_root" "$harness" '')

  return 1
}

first_agent_prompt_for_harness() {
  local harness=$1
  local prompt_file
  local prompts_root="$repo_root/agents/prompts/harnesses/$harness"

  [[ -d "$prompts_root" ]] || return 1

  prompt_file="$(
    find "$prompts_root" \
      -maxdepth 1 \
      -type f \
      -name '*.md' \
      | LC_ALL=C sort \
      | sed -n '1p'
  )"
  [[ -n "$prompt_file" ]] || return 1
  prompt_file="${prompt_file##*/}"
  printf '%s\n' "${prompt_file%.md}"
}

first_agent_prompt_harness() {
  local harness_dir
  local prompts_root="$repo_root/agents/prompts/harnesses"

  [[ -d "$prompts_root" ]] || return 1

  while IFS= read -r harness_dir; do
    [[ -n "$harness_dir" ]] || continue
    first_agent_prompt_for_harness "${harness_dir##*/}" >/dev/null || continue
    printf '%s\n' "${harness_dir##*/}"
    return 0
  done < <(
    find "$prompts_root" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      | LC_ALL=C sort
  )

  return 1
}

write_agent_harness_model_config() {
  local config_path
  local harness=$2
  local home_config
  local home_dir=$1
  local model=$3
  local model_key

  home_config="$(dotfiles_agent_harness_home_config "$repo_root" "$harness")" \
    || fail "harness should define home_config: $harness"
  model_key="$(dotfiles_agent_harness_model_config_key "$repo_root" "$harness")" \
    || fail "harness should define model_config_key: $harness"
  config_path="$home_dir/$home_config"
  mkdir -p "$(dirname -- "$config_path")"

  case "$config_path" in
    *.json)
      if [[ "$model_key" == *.* ]]; then
        printf '{\n  "%s": {\n    "%s": "%s"\n  }\n}\n' \
          "${model_key%%.*}" \
          "${model_key#*.}" \
          "$model" >"$config_path"
      else
        printf '{"%s":"%s"}\n' "$model_key" "$model" >"$config_path"
      fi
      ;;
    *)
      printf "%s = '%s'\n" "$model_key" "$model" >"$config_path"
      ;;
  esac
}

check_agent_skill_symlink_prefix_filter() {
  local actual
  local expected
  local status
  local tmp_home
  local tmp_repo

  actual="$(make_temp_file)"
  expected="$(make_temp_file)"
  tmp_repo="$(make_temp_dir)"

  mkdir -p \
    "$tmp_repo/agents/harnesses" \
    "$tmp_repo/agents/skills/src/frontend/editor/open-code" \
    "$tmp_repo/agents/skills/src/services/api/deploy-code" \
    "$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/open-code" \
    "$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/deploy-code"
  cp -R "$repo_root/agents/scripts" "$tmp_repo/agents/scripts"
  printf '%s\n' \
    'home_config: .codex/config.toml' \
    'model_config_key: model' \
    'skills_dir: .agents/skills' >"$tmp_repo/agents/harnesses/codex.yaml"
  : >"$tmp_repo/agents/skills/src/frontend/editor/open-code/SKILL.md"
  : >"$tmp_repo/agents/skills/src/services/api/deploy-code/SKILL.md"
  : >"$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/open-code/SKILL.md"
  : >"$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/deploy-code/SKILL.md"

  tmp_home="$(make_temp_dir)"
  "$tmp_repo/agents/scripts/symlink-all.bash" \
    --home "$tmp_home" \
    --harness codex \
    --model gpt-5.5 \
    frontend >"$actual"
  grep -F -q 'Symlinking selected skills' "$actual" \
    || fail 'symlink-all.bash should print a user-facing header'
  grep -F -q 'Selected skills: 1' "$actual" \
    || fail 'symlink-all.bash should summarize selected skills'
  grep -F -q '[link] open-code -> codex/gpt-5.5' "$actual" \
    || fail 'symlink-all.bash should print concise per-skill link status'
  grep -F -q 'Done: processed 1 skill(s).' "$actual" \
    || fail 'symlink-all.bash should print a completion summary'
  assert_symlink \
    "$tmp_home/.agents/skills/open-code" \
    "$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/open-code"
  [[ ! -e "$tmp_home/.agents/skills/deploy-code" ]] \
    || fail "symlink-all.bash prefix filter should not link skills outside the prefix"

  tmp_home="$(make_temp_dir)"
  "$tmp_repo/agents/scripts/symlink-all.bash" \
    --home "$tmp_home" \
    --harness codex \
    --model gpt-5.5 \
    frontend/editor/open-code >/dev/null
  assert_symlink \
    "$tmp_home/.agents/skills/open-code" \
    "$tmp_repo/agents/skills/artifacts/codex/gpt-5.5/skills/open-code"
  [[ ! -e "$tmp_home/.agents/skills/deploy-code" ]] \
    || fail "symlink-all.bash exact prefix should not link sibling skills"

  set +e
  "$tmp_repo/agents/scripts/symlink-all.bash" \
    --home "$tmp_home" \
    --harness codex \
    --model gpt-5.5 \
    frontend/missing >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "unknown symlink-all prefix should fail with status 2, got $status"
  printf '%s\n' \
    'symlink-all.bash: no source skills found under prefix: frontend/missing' >"$expected"
  diff -u "$expected" "$actual"

  set +e
  "$tmp_repo/agents/scripts/symlink-all.bash" \
    --home "$tmp_home" \
    --harness codex \
    --model gpt-5.5 \
    --skill open-code \
    frontend >"$actual" 2>&1
  status=$?
  set -e
  [[ "$status" -eq 2 ]] || fail "symlink-all prefix plus --skill should fail with status 2, got $status"
  printf '%s\n' \
    'symlink-all.bash: use either a skill prefix or --skill filters, not both' >"$expected"
  diff -u "$expected" "$actual"
}

check_agent_skill_symlink_scripts() {
  local alias_model
  local artifact
  local checked=0
  local checked_alias=0
  local harness
  local model
  local skill
  local skills_dir
  local target
  local tmp_home

  while IFS= read -r harness; do
    [[ -n "$harness" ]] || continue
    artifact="$(first_agent_skill_artifact_for_harness "$harness")" || continue
    model="$(dotfiles_agent_artifact_model "$artifact" "$harness")" \
      || fail "artifact should include a model: $artifact"
    skill="$(first_agent_skill_for_artifact "$artifact")" \
      || fail "artifact should contain at least one skill: $artifact"
    skills_dir="$(dotfiles_agent_harness_skills_dir "$repo_root" "$harness")" \
      || fail "harness should define skills_dir: $harness"
    target="$repo_root/agents/skills/artifacts/$artifact/skills/$skill"

    tmp_home="$(make_temp_dir)"
    write_agent_harness_model_config "$tmp_home" "$harness" "$model"
    "$repo_root/agents/scripts/symlink-skill.bash" --home "$tmp_home" "$skill" >/dev/null
    assert_symlink "$tmp_home/$skills_dir/$skill" "$target"

    tmp_home="$(make_temp_dir)"
    write_agent_harness_model_config "$tmp_home" "$harness" "$model"
    "$repo_root/agents/scripts/symlink-all.bash" --home "$tmp_home" --skill "$skill" >/dev/null
    assert_symlink "$tmp_home/$skills_dir/$skill" "$target"

    tmp_home="$(make_temp_dir)"
    "$repo_root/agents/scripts/symlink-all.bash" \
      --home "$tmp_home" \
      --harness "$harness" \
      --model "$model" \
      --skill "$skill" >/dev/null
    assert_symlink "$tmp_home/$skills_dir/$skill" "$target"

    alias_model="$(dotfiles_agent_harness_model_alias "$repo_root" "$harness" best || true)"
    if [[ -n "$alias_model" && -d "$repo_root/agents/skills/artifacts/$harness/$alias_model/skills/$skill" ]]; then
      target="$repo_root/agents/skills/artifacts/$harness/$alias_model/skills/$skill"

      tmp_home="$(make_temp_dir)"
      write_agent_harness_model_config "$tmp_home" "$harness" best
      "$repo_root/agents/scripts/symlink-skill.bash" --home "$tmp_home" "$skill" >/dev/null
      assert_symlink "$tmp_home/$skills_dir/$skill" "$target"

      tmp_home="$(make_temp_dir)"
      "$repo_root/agents/scripts/symlink-all.bash" \
        --home "$tmp_home" \
        --harness "$harness" \
        --model best \
        --skill "$skill" >/dev/null
      assert_symlink "$tmp_home/$skills_dir/$skill" "$target"
      checked_alias=$((checked_alias + 1))
    fi

    checked=$((checked + 1))
  done < <(dotfiles_agent_harnesses "$repo_root")

  ((checked > 0)) || fail 'no agent skill artifacts found for symlink script verification'
  ((checked_alias > 0)) || fail 'no agent model alias found for symlink script verification'
  check_agent_skill_symlink_prefix_filter
}

check_managed_targets() {
  local expected
  local actual

  expected="$(make_temp_file)"
  actual="$(make_temp_file)"

  dotfiles_emit_managed_paths "$repo_root" | sort >"$expected"
  "$repo_root/bootstrap.sh" --list-managed | sort >"$actual"
  diff -u "$expected" "$actual"
}

check_temp_apply() {
  local manifest_path
  local manifest_ifs
  local tmp_home
  local kind
  local rel_path
  local source_path

  tmp_home="$(make_temp_dir)"
  manifest_path="$(make_temp_file)"
  manifest_ifs=$'\t'

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    "$repo_root/bootstrap.sh" --verbose >/dev/null

  dotfiles_emit_manifest "$repo_root" >"$manifest_path"

  while IFS="$manifest_ifs" read -r kind rel_path source_path; do
    case "$kind" in
      dir)
        assert_directory "$tmp_home/$rel_path"
        ;;
      leaf)
        assert_symlink "$tmp_home/$rel_path" "$repo_root/$source_path"
        ;;
    esac
  done <"$manifest_path"
}

check_live_home_converged() {
  local diff_output

  diff_output="$(make_temp_file)"
  "$repo_root/bootstrap.sh" --dry-run --verbose >"$diff_output"

  if [[ -s "$diff_output" ]]; then
    cat "$diff_output"
    fail "live home differs from managed target state; run ./bootstrap.sh"
  fi
}

run_bash_fixture() {
  local fixture_name="$1"
  shift

  run_bash_fixtures "$fixture_name" -- "$@"
}

run_sh_fixture() {
  local fixture_name="$1"
  shift

  run_sh_fixtures "$fixture_name" -- "$@"
}

run_zsh_fixture() {
  local fixture_name="$1"
  shift

  run_zsh_fixtures "$fixture_name" -- "$@"
}

run_bash_fixtures() {
  local fixture_names=()

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" \
    bash -lic "source ${fixture_root@Q}/bash-fixture-runner.bash" \
    bash "${fixture_names[@]}"
}

run_sh_fixtures() {
  local fixture_names=()

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" \
    sh -lic ". ${fixture_root@Q}/sh-fixture-runner.sh" \
    sh "${fixture_names[@]}"
}

run_zsh_fixtures() {
  local env_arg
  local fixture_names=()
  local zdotdir="$HOME"

  while [[ ${1:-} != -- ]]; do
    fixture_names+=("$1")
    shift
  done
  shift

  for env_arg in "$@"; do
    case "$env_arg" in
      HOME=*)
        zdotdir="${env_arg#HOME=}"
        ;;
    esac
  done

  # Run as interactive login shells so startup files load before the fixture assertions.
  env "$@" DOTFILES_VERIFY_FIXTURE_ROOT="$fixture_root" ZDOTDIR="$zdotdir" \
    zsh -lic "source ${fixture_root@Q}/zsh-fixture-runner.zsh" \
    zsh "${fixture_names[@]}"
}

assert_bash_startup() {
  run_bash_fixture bash-startup.bash "$@"
}

assert_bash_rerunnable() {
  run_bash_fixture bash-rerunnable.bash "$@"
}

assert_sh_startup() {
  run_sh_fixture sh-startup.sh "$@"
}

assert_sh_rerunnable() {
  run_sh_fixture sh-rerunnable.sh "$@"
}

assert_zsh_startup() {
  run_zsh_fixture zsh-startup.zsh "$@"
}

assert_zsh_rerunnable() {
  run_zsh_fixture zsh-rerunnable.zsh "$@"
}

check_zsh_vi_mode_operators() {
  local tmp_home

  tmp_home="$(make_temp_dir)"

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    XDG_CACHE_HOME="$tmp_home/.cache" \
    "$repo_root/bootstrap.sh" >/dev/null

  zsh "$fixture_root/zsh-vi-mode-operators.zsh" "$tmp_home"
}

assert_shell_startup_edge_cases() {
  local fixture_path
  local startup_stderr
  local tmux_log
  local tmp_home

  tmp_home="$(make_temp_dir)"
  startup_stderr="$(make_temp_file)"
  tmux_log="$(make_temp_file)"
  fixture_path="$fixture_root/fake-fzf-no-shell-support:$fixture_root/fake-generated-completion-no-support:${PATH:-}"

  HOME="$tmp_home" \
    XDG_CONFIG_HOME="$tmp_home/.config" \
    XDG_STATE_HOME="$tmp_home/.local/state" \
    "$repo_root/bootstrap.sh" >/dev/null
  ln -s "$fixture_root/fake-tmux/tmux" "$tmp_home/.local/bin/tmux"

  run_sh_fixtures sh-startup.sh tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    HOME="$tmp_home" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>"$startup_stderr"

  run_bash_fixtures bash-startup.bash tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE \
    HOME="$tmp_home" \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>>"$startup_stderr"

  run_zsh_fixtures zsh-startup.zsh tmux-default-wrapper.sh -- \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST \
    HOME="$tmp_home" \
    PATH="$fixture_path" \
    DOTFILES_FAKE_TMUX_LOG="$tmux_log" \
    2>>"$startup_stderr"

  if grep -q "unknown option: --\\(bash\\|zsh\\)" "$startup_stderr"; then
    cat "$startup_stderr" >&2
    fail "unsupported fzf shell generators should not print startup errors"
  fi

  if grep -q "unknown command: completion" "$startup_stderr"; then
    cat "$startup_stderr" >&2
    fail "unsupported generated completions should not print startup errors"
  fi
}

check_shell_startup() {
  assert_sh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME

  assert_sh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1

  assert_sh_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME

  assert_bash_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE

  # Cursor can inherit exported sentinels from an older parent shell session.
  assert_bash_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1 \
    DOTFILES_BASH_RC_LOADED=1

  assert_bash_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u HISTFILESIZE

  assert_zsh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST

  assert_zsh_startup \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST \
    DOTFILES_PATHS_LOADED=1 \
    DOTFILES_SHELL_PROFILE_LOADED=1 \
    DOTFILES_SHELL_RC_LOADED=1 \
    DOTFILES_ZSH_RC_LOADED=1 \
    DOTFILES_ZSH_PROMPT_LOADED=1 \
    DOTFILES_ZSH_COMPLETION_LOADED=1

  assert_zsh_rerunnable \
    -u XDG_CONFIG_HOME \
    -u XDG_CACHE_HOME \
    -u XDG_DATA_HOME \
    -u XDG_STATE_HOME \
    -u HISTFILE \
    -u HISTSIZE \
    -u SAVEHIST

  assert_shell_startup_edge_cases
}

check_static_analysis_suite() {
  log_suite "static analysis"
  run_timed_check "shell syntax" check_shell_syntax
  run_timed_check "shell static analysis" check_shell_lint
}

check_linting_suite() {
  log_suite "linting"
  run_timed_check "shell formatting" check_shell_format
}

check_functionality_suite() {
  log_suite "functionality"
  run_timed_check "dev tool wrappers" check_dev_tool_wrappers
  run_timed_check "submodule file enumeration" check_submodule_file_enumeration
  run_timed_check "tmux config" check_tmux_config
  run_timed_check "tmux control-mode options" check_tmux_control_mode_options
  run_timed_check "clipboard wrapper" check_clipboard_wrapper
  run_timed_check "agent skill source discovery" check_agent_skill_source_discovery
  run_timed_check "agent update script options" check_agent_update_script_options
  run_timed_check "agent harness config parser" check_agent_harness_config_parser
  run_timed_check "agent skill symlink scripts" check_agent_skill_symlink_scripts
  run_timed_check "managed target list" check_managed_targets
  run_timed_check "bootstrap in a temporary home" check_temp_apply
  run_timed_check "live home convergence" check_live_home_converged
  run_timed_check "shell startup smoke tests" check_shell_startup
  run_timed_check "zsh vi-mode operator smoke test" check_zsh_vi_mode_operators
}

main() {
  local suite_start
  local suite_total

  suite_start="$SECONDS"

  require_command awk
  require_command bash
  require_command comm
  require_command diff
  require_command git
  require_command readlink
  require_command shellcheck
  require_command shfmt
  require_command sort
  require_command zsh

  cd "$repo_root"

  # Keep verification grouped for scanability while retaining linear fail-fast execution.
  check_static_analysis_suite
  check_linting_suite
  check_functionality_suite

  suite_total=$((SECONDS - suite_start))
  log_success "$(format_duration "$suite_total")"
}

main "$@"
