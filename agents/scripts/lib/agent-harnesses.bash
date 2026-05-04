#!/usr/bin/env bash

dotfiles_agent_harnesses() {
  local repo_root=$1
  local harness_file
  local harnesses_root="$repo_root/agents/harnesses"

  [[ -d "$harnesses_root" ]] || return 0

  find "$harnesses_root" \
    -maxdepth 1 \
    -type f \
    -name '*.yaml' \
    | LC_ALL=C sort \
    | while IFS= read -r harness_file; do
      harness_file="${harness_file##*/}"
      printf '%s\n' "${harness_file%.yaml}"
    done
}

dotfiles_agent_harness_is_known() {
  local repo_root=$1
  local harness=$2

  dotfiles_agent_target_id_is_valid "$harness" \
    && [[ -f "$repo_root/agents/harnesses/$harness.yaml" ]]
}

dotfiles_agent_harness_command() {
  local repo_root=$1
  local harness=$2

  dotfiles_agent_harness_is_known "$repo_root" "$harness" || return 1
  printf '%s\n' "$harness"
}

dotfiles_agent_target_id_is_valid() {
  case "$1" in
    '' | *[!A-Za-z0-9._-]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

dotfiles_agent_source_dirs() {
  local repo_root=$1
  local source_root_rel=${2%/}
  local marker_file=$3
  local source_file
  local source_root="$repo_root/$source_root_rel"

  [[ -d "$source_root" ]] || return 0

  # Source objects are marker-file directories so teams can nest them by domain.
  find "$source_root" \
    -type f \
    -name "$marker_file" \
    | LC_ALL=C sort \
    | while IFS= read -r source_file; do
      source_file="${source_file%/"$marker_file"}"
      printf '%s\n' "${source_file#"$source_root"/}"
    done
}

dotfiles_agent_source_id() {
  local source_relpath=${1%/}
  printf '%s\n' "${source_relpath##*/}"
}

dotfiles_agent_source_matches() {
  local repo_root=$1
  local source_root_rel=$2
  local marker_file=$3
  local requested=$4
  local source_relpath

  requested=${requested%/}
  while IFS= read -r source_relpath; do
    [[ "$(dotfiles_agent_source_id "$source_relpath")" == "$requested" ]] \
      || continue
    printf '%s\n' "$source_relpath"
  done < <(dotfiles_agent_source_dirs "$repo_root" "$source_root_rel" "$marker_file")
}

dotfiles_agent_source_format_paths() {
  local path
  local separator=''

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf '%s%s' "$separator" "$path"
    separator=' '
  done
}

dotfiles_agent_source_skill_dirs() {
  dotfiles_agent_source_dirs "$1" agents/skills/src SKILL.md
}

dotfiles_agent_source_skill_id() {
  dotfiles_agent_source_id "$1"
}

dotfiles_agent_source_skill_matches() {
  dotfiles_agent_source_matches "$1" agents/skills/src SKILL.md "$2"
}

dotfiles_agent_source_skill_format_paths() {
  dotfiles_agent_source_format_paths
}

dotfiles_agent_source_prompt_dirs() {
  dotfiles_agent_source_dirs "$1" agents/prompts/src PROMPT.md
}

dotfiles_agent_source_prompt_id() {
  dotfiles_agent_source_id "$1"
}

dotfiles_agent_source_prompt_matches() {
  dotfiles_agent_source_matches "$1" agents/prompts/src PROMPT.md "$2"
}

dotfiles_agent_source_prompt_format_paths() {
  dotfiles_agent_source_format_paths
}

dotfiles_agent_artifact_name() {
  local harness=$1
  local model=$2

  dotfiles_agent_target_id_is_valid "$harness" || return 1
  [[ -n "$model" ]] || return 1
  dotfiles_agent_target_id_is_valid "$model" || return 1
  printf '%s/%s\n' "$harness" "$model"
}

dotfiles_agent_harness_model_alias() {
  dotfiles_agent_harness_config_map_value "$1" "$2" model_aliases "$3"
}

dotfiles_agent_harness_normalize_model() {
  local repo_root=$1
  local harness=$2
  local model=$3

  dotfiles_agent_harness_model_alias "$repo_root" "$harness" "$model" \
    || printf '%s\n' "$model"
}

dotfiles_agent_artifact_harness() {
  local artifact=$1

  case "$artifact" in
    */*)
      printf '%s\n' "${artifact%%/*}"
      ;;
    *)
      return 1
      ;;
  esac
}

dotfiles_agent_artifact_model() {
  local artifact=$1
  local harness=${2:-}
  local model

  if [[ -z "$harness" ]]; then
    harness="$(dotfiles_agent_artifact_harness "$artifact")" || return 1
  fi

  case "$artifact" in
    "$harness"/*)
      model="${artifact#"$harness"/}"
      [[ -n "$model" ]] || return 1
      printf '%s\n' "$model"
      ;;
    *) return 1 ;;
  esac
}

dotfiles_agent_existing_artifacts() {
  local repo_root=$1
  local artifacts_root="$repo_root/agents/skills/artifacts"
  local artifact_dir

  [[ -d "$artifacts_root" ]] || return 0

  find "$artifacts_root" \
    -mindepth 2 \
    -maxdepth 2 \
    -type d \
    | LC_ALL=C sort \
    | while IFS= read -r artifact_dir; do
      printf '%s\n' "${artifact_dir#"$artifacts_root"/}"
    done
}

dotfiles_agent_select_artifacts() {
  local repo_root=$1
  local harness=$2
  local model=$3
  local artifact
  local artifact_harness
  local artifact_model
  local selected_model

  if [[ -n "$harness" && -n "$model" ]]; then
    selected_model="$(dotfiles_agent_harness_normalize_model "$repo_root" "$harness" "$model")"
    dotfiles_agent_artifact_name "$harness" "$selected_model"
    return
  fi

  dotfiles_agent_existing_artifacts "$repo_root" | while IFS= read -r artifact; do
    [[ -n "$artifact" ]] || continue
    artifact_harness="$(dotfiles_agent_artifact_harness "$artifact")" || continue
    artifact_model="$(dotfiles_agent_artifact_model "$artifact" "$artifact_harness")" || continue

    if [[ -n "$harness" && "$artifact_harness" != "$harness" ]]; then
      continue
    fi
    selected_model="$(dotfiles_agent_harness_normalize_model "$repo_root" "$artifact_harness" "$model")"
    if [[ -n "$model" && "$artifact_model" != "$selected_model" ]]; then
      continue
    fi

    printf '%s\n' "$artifact"
  done
}

dotfiles_agent_harness_is_installed() {
  local repo_root=$1
  local harness=$2
  local command_name
  command_name="$(dotfiles_agent_harness_command "$repo_root" "$harness")" || return 1
  command -v "$command_name" >/dev/null 2>&1
}

dotfiles_agent_harness_yaml_scalar() {
  local value=$1

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  case "$value" in
    \"*\")
      value=${value#\"}
      value=${value%\"}
      ;;
    \'*\')
      value=${value#\'}
      value=${value%\'}
      ;;
  esac

  printf '%s\n' "$value"
}

dotfiles_agent_harness_config_inline_list() {
  local char
  local i
  local item=''
  local quote=''
  local value=$1

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  case "$value" in
    '['*']')
      value=${value#'['}
      value=${value%']'}
      ;;
    *)
      return 1
      ;;
  esac

  # Split only on commas outside quotes so each YAML array item stays one argv.
  for ((i = 0; i < ${#value}; i++)); do
    char=${value:i:1}
    if [[ -n "$quote" ]]; then
      item+=$char
      [[ "$char" == "$quote" ]] && quote=''
      continue
    fi

    case "$char" in
      \" | \')
        quote=$char
        item+=$char
        ;;
      ,)
        dotfiles_agent_harness_yaml_scalar "$item"
        item=''
        ;;
      *)
        item+=$char
        ;;
    esac
  done

  [[ -z "$quote" ]] || return 1
  if [[ -n "${item//[[:space:]]/}" || -n "$value" ]]; then
    dotfiles_agent_harness_yaml_scalar "$item"
  fi
}

dotfiles_agent_harness_config_scalar() {
  local repo_root=$1
  local harness=$2
  local key=$3
  local config_file="$repo_root/agents/harnesses/$harness.yaml"
  local line
  local value

  [[ -f "$config_file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      "$key:"*)
        value=${line#"$key:"}
        [[ -n "${value//[[:space:]]/}" ]] || return 1
        dotfiles_agent_harness_yaml_scalar "$value"
        return 0
        ;;
    esac
  done <"$config_file"

  return 1
}

dotfiles_agent_harness_config_list() {
  local repo_root=$1
  local harness=$2
  local key=$3
  local config_file="$repo_root/agents/harnesses/$harness.yaml"
  local in_list=0
  local item
  local line
  local value

  [[ -f "$config_file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      "$key:")
        in_list=1
        continue
        ;;
      "$key:"*)
        value=${line#"$key:"}
        [[ -n "${value//[[:space:]]/}" ]] || return 1
        dotfiles_agent_harness_config_inline_list "$value"
        return
        ;;
      [![:space:]]*)
        in_list=0
        ;;
    esac

    if ((in_list)); then
      case "$line" in
        "  - "*)
          item=${line#"  - "}
          dotfiles_agent_harness_yaml_scalar "$item"
          ;;
        '' | '  #'*) ;;
      esac
    fi
  done <"$config_file"
}

dotfiles_agent_harness_config_map_value() {
  local repo_root=$1
  local harness=$2
  local key=$3
  local map_key=$4
  local config_file="$repo_root/agents/harnesses/$harness.yaml"
  local entry_key
  local in_map=0
  local line
  local value

  [[ -f "$config_file" ]] || return 1

  # Harness YAML is deliberately tiny; support only top-level scalar maps here.
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      "$key:")
        in_map=1
        continue
        ;;
      "$key:"*)
        return 1
        ;;
      [![:space:]]*)
        in_map=0
        ;;
    esac

    if ((in_map)); then
      case "$line" in
        "  "*":"*)
          entry_key=${line#"  "}
          value=${entry_key#*:}
          entry_key=${entry_key%%:*}
          entry_key="$(dotfiles_agent_harness_yaml_scalar "$entry_key")"
          value="$(dotfiles_agent_harness_yaml_scalar "$value")"
          if [[ "$entry_key" == "$map_key" && -n "$value" ]]; then
            printf '%s\n' "$value"
            return 0
          fi
          ;;
        '' | '  #'*) ;;
      esac
    fi
  done <"$config_file"

  return 1
}

dotfiles_agent_harness_outputs() {
  dotfiles_agent_harness_config_list "$1" "$2" outputs
}

dotfiles_agent_harness_home_config() {
  dotfiles_agent_harness_config_scalar "$1" "$2" home_config
}

dotfiles_agent_harness_skills_dir() {
  dotfiles_agent_harness_config_scalar "$1" "$2" skills_dir
}

dotfiles_agent_harness_model_config_key() {
  dotfiles_agent_harness_config_scalar "$1" "$2" model_config_key
}

dotfiles_agent_harness_runner_args() {
  dotfiles_agent_harness_config_list "$1" "$2" runner_args
}

dotfiles_agent_harness_runner_is_configured() {
  [[ -n "$(dotfiles_agent_harness_runner_args "$1" "$2")" ]]
}

dotfiles_agent_harness_installed() {
  local repo_root=$1
  local harness
  dotfiles_agent_harnesses "$repo_root" | while IFS= read -r harness; do
    if dotfiles_agent_harness_is_installed "$repo_root" "$harness"; then
      printf '%s\n' "$harness"
    fi
  done
}

dotfiles_agent_harness_installed_runners() {
  local repo_root=$1
  local harness
  dotfiles_agent_harnesses "$repo_root" | while IFS= read -r harness; do
    if dotfiles_agent_harness_is_installed "$repo_root" "$harness" \
      && dotfiles_agent_harness_runner_is_configured "$repo_root" "$harness"; then
      printf '%s\n' "$harness"
    fi
  done
}

dotfiles_agent_harness_print_list() {
  local harness
  while IFS= read -r harness; do
    [[ -n "$harness" ]] || continue
    printf '  - %s\n' "$harness"
  done
}

dotfiles_agent_harness_has_tty() {
  [[ -t 0 && -t 1 && -r /dev/tty && -w /dev/tty ]]
}

dotfiles_agent_harness_validate_policy() {
  local repo_root=$1

  case "${DOTFILES_AGENT_HARNESS_MISSING_POLICY:-}" in
    '' | skip)
      DOTFILES_AGENT_HARNESS_MISSING_POLICY=skip
      DOTFILES_AGENT_HARNESS_FALLBACK=''
      ;;
    fallback)
      [[ -n "${DOTFILES_AGENT_HARNESS_FALLBACK:-}" ]] \
        || return 1
      dotfiles_agent_harness_is_known "$repo_root" "$DOTFILES_AGENT_HARNESS_FALLBACK" \
        || return 1
      dotfiles_agent_harness_is_installed "$repo_root" "$DOTFILES_AGENT_HARNESS_FALLBACK" \
        || return 1
      dotfiles_agent_harness_runner_is_configured "$repo_root" "$DOTFILES_AGENT_HARNESS_FALLBACK" \
        || return 1
      ;;
    *)
      return 1
      ;;
  esac
}

dotfiles_agent_harness_select_fallback() {
  local installed=$1
  local harness
  local index
  local choice

  index=1
  while IFS= read -r harness; do
    [[ -n "$harness" ]] || continue
    printf '  %d) %s\n' "$index" "$harness" >/dev/tty
    index=$((index + 1))
  done <<<"$installed"

  while :; do
    printf 'Select fallback harness [1]: ' >/dev/tty
    IFS= read -r choice </dev/tty
    choice=${choice:-1}
    case "$choice" in
      *[!0-9]* | '')
        printf 'Enter a number from the list.\n' >/dev/tty
        continue
        ;;
    esac

    index=1
    while IFS= read -r harness; do
      [[ -n "$harness" ]] || continue
      if [[ "$index" -eq "$choice" ]]; then
        DOTFILES_AGENT_HARNESS_MISSING_POLICY=fallback
        DOTFILES_AGENT_HARNESS_FALLBACK=$harness
        return 0
      fi
      index=$((index + 1))
    done <<<"$installed"

    printf 'Enter a number from the list.\n' >/dev/tty
  done
}

dotfiles_agent_harness_preflight() {
  local repo_root=$1
  local missing=$2
  local installed
  local fallback_candidates
  local choice

  if [[ "${DOTFILES_AGENT_HARNESS_PREFLIGHTED:-}" == 1 ]]; then
    dotfiles_agent_harness_validate_policy "$repo_root" || return 1
    export DOTFILES_AGENT_HARNESS_MISSING_POLICY
    export DOTFILES_AGENT_HARNESS_FALLBACK
    return 0
  fi

  installed="$(dotfiles_agent_harness_installed "$repo_root")"
  fallback_candidates="$(dotfiles_agent_harness_installed_runners "$repo_root")"

  printf 'Missing agent harnesses:\n' >&2
  dotfiles_agent_harness_print_list <<<"$missing" >&2

  if [[ -n "$installed" ]]; then
    printf 'Installed agent harnesses:\n' >&2
    dotfiles_agent_harness_print_list <<<"$installed" >&2
  else
    printf 'No supported agent harnesses are installed.\n' >&2
  fi

  if [[ -n "$fallback_candidates" && "$fallback_candidates" != "$installed" ]]; then
    printf 'Installed fallback-capable harnesses:\n' >&2
    dotfiles_agent_harness_print_list <<<"$fallback_candidates" >&2
  fi

  if ! dotfiles_agent_harness_has_tty; then
    DOTFILES_AGENT_HARNESS_MISSING_POLICY=skip
    DOTFILES_AGENT_HARNESS_FALLBACK=''
    printf 'No interactive terminal is available; missing harness targets will be skipped.\n' >&2
  else
    while :; do
      printf 'Skip missing harness targets or fall back to an installed harness? [s/f]: ' >/dev/tty
      IFS= read -r choice </dev/tty
      choice=${choice:-s}
      case "$choice" in
        s | S | skip | Skip)
          DOTFILES_AGENT_HARNESS_MISSING_POLICY=skip
          DOTFILES_AGENT_HARNESS_FALLBACK=''
          break
          ;;
        f | F | fallback | Fallback)
          if [[ -z "$fallback_candidates" ]]; then
            printf 'No installed runner-capable harness is available for fallback.\n' >/dev/tty
            continue
          fi
          dotfiles_agent_harness_select_fallback "$fallback_candidates"
          break
          ;;
        *)
          printf 'Enter s to skip or f to choose a fallback harness.\n' >/dev/tty
          ;;
      esac
    done
  fi

  DOTFILES_AGENT_HARNESS_PREFLIGHTED=1
  export DOTFILES_AGENT_HARNESS_MISSING_POLICY
  export DOTFILES_AGENT_HARNESS_FALLBACK
  export DOTFILES_AGENT_HARNESS_PREFLIGHTED
}
