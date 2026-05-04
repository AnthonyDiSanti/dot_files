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
    'Usage:' \
    '  agents/scripts/symlink-skill.bash [options] <skill>' \
    '' \
    'Symlinks one runtime skill artifact into selected harness home skill directories.' \
    '<skill> may be a globally unique skill directory name or a path relative to agents/skills/src/.' \
    '' \
    'Options:' \
    '  --home HOME        Home tree to update (default: repo home/).' \
    '  --harness HARNESS  Limit to one harness; with --model, bypass home-config discovery.' \
    '  --model MODEL      Limit to one model; with --harness, bypass home-config discovery.' \
    '  --verbose          Show extra path and discovery details.' \
    '' \
    'Discovery:' \
    '  Without both --harness and --model, targets are discovered from harness home configs.' \
    '  Harness-owned model_aliases are normalized before artifact selection.' \
    '  Pass both --harness and --model when the target home has no model config yet.'
}

die() {
  printf '%s: %s\n' "$script_name" "$*" >&2
  exit 2
}

log() {
  printf '%s\n' "$*"
}

verbose_log() {
  ((verbose == 1)) || return 0
  log "$@"
}

repo_relative() {
  local path=$1
  printf '%s\n' "${path#"$repo_root"/}"
}

absolute_path() {
  local path=$1

  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$PWD/$path" ;;
  esac
}

trim_config_value() {
  local value=$1

  value=${value%%#*}
  value=${value%%,}
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

  [[ -n "$value" ]] || return 1
  printf '%s\n' "$value"
}

configured_json_model_from_dotted_key() {
  local child
  local config_path=$1
  local depth=0
  local i
  local in_parent=0
  local key_path=$2
  local line
  local parent
  local value

  parent=${key_path%%.*}
  child=${key_path#*.}
  [[ -n "$parent" && -n "$child" && "$child" != *.* ]] || return 1

  # Fast path for compact JSON, then a tiny pretty-JSON parser for managed
  # settings files such as `.gemini/settings.json`.
  value="$(
    sed -nE "s/.*\"$parent\"[[:space:]]*:[[:space:]]*\\{[^}]*\"$child\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\\1/p" \
      "$config_path" \
      | sed -n '1p'
  )"
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value"
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    if ((in_parent == 0)); then
      [[ "$line" =~ \"$parent\"[[:space:]]*:[[:space:]]*\{ ]] || continue
      in_parent=1
    elif [[ "$line" =~ \"$child\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
      return 0
    fi

    if ((in_parent)); then
      for ((i = 0; i < ${#line}; i++)); do
        case "${line:i:1}" in
          '{') depth=$((depth + 1)) ;;
          '}') depth=$((depth - 1)) ;;
        esac
      done
      ((depth > 0)) || return 1
    fi
  done <"$config_path"

  return 1
}

configured_model_from_home_config() {
  local config_path=$1
  local model_key=$2
  local line

  case "$config_path" in
    *.json)
      if [[ "$model_key" == *.* ]]; then
        configured_json_model_from_dotted_key "$config_path" "$model_key"
        return
      fi
      while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ \"$model_key\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
          printf '%s\n' "${BASH_REMATCH[1]}"
          return 0
        fi
      done <"$config_path"
      ;;
    *)
      while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*\[ ]] && return 1
        if [[ "$line" =~ ^[[:space:]]*${model_key}[[:space:]]*= ]]; then
          trim_config_value "${line#*=}"
          return
        fi
      done <"$config_path"
      ;;
  esac

  return 1
}

resolve_source_skill() {
  local requested=${1%/}
  local exact_dir="$repo_root/agents/skills/src/$requested"
  local matches
  local count=0
  local match
  local one=''

  case "$requested" in
    '' | /* | . | ./ | ./* | ../* | */../* | */.. | */./* | */. | *//*)
      die "invalid source skill path: $requested (expected a skill directory name or path relative to agents/skills/src/)"
      ;;
  esac

  if [[ -f "$exact_dir/SKILL.md" ]]; then
    printf '%s\n' "$requested"
    return 0
  fi

  matches="$(dotfiles_agent_source_skill_matches "$repo_root" "$requested")"
  while IFS= read -r match; do
    [[ -n "$match" ]] || continue
    one=$match
    count=$((count + 1))
  done <<<"$matches"

  case "$count" in
    0)
      die "unknown source skill: $requested (expected a skill directory name or src-relative path)"
      ;;
    1)
      printf '%s\n' "$one"
      ;;
    *)
      die "source skill directory name conflict: $requested matches multiple src paths ($(dotfiles_agent_source_skill_format_paths <<<"$matches")); every source skill directory name must be globally unique because runtime artifacts use it as the skill id"
      ;;
  esac
}

require_unique_source_skill_id() {
  local skill_id=$1
  local matches
  local count=0
  local match

  matches="$(dotfiles_agent_source_skill_matches "$repo_root" "$skill_id")"
  while IFS= read -r match; do
    [[ -n "$match" ]] || continue
    count=$((count + 1))
  done <<<"$matches"

  ((count <= 1)) \
    || die "source skill directory name conflict: $skill_id is used by multiple src paths ($(dotfiles_agent_source_skill_format_paths <<<"$matches")); every source skill directory name must be globally unique because runtime artifacts use it as the skill id"
}

configure_skill() {
  requested_skill=$1
  skill_source_relpath="$(resolve_source_skill "$requested_skill")"
  skill="$(dotfiles_agent_source_skill_id "$skill_source_relpath")"
  dotfiles_agent_target_id_is_valid "$skill" \
    || die "invalid source skill directory name: $skill (use only letters, numbers, dots, underscores, and hyphens)"
  require_unique_source_skill_id "$skill"
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

discovered_artifacts() {
  local config_path
  local harness
  local home_config
  local model
  local model_key
  local selected_model
  local skills_dir

  dotfiles_agent_harnesses "$repo_root" | while IFS= read -r harness; do
    [[ -n "$harness" ]] || continue
    [[ -z "$target_harness" || "$target_harness" == "$harness" ]] || continue

    home_config="$(dotfiles_agent_harness_home_config "$repo_root" "$harness")" || continue
    skills_dir="$(dotfiles_agent_harness_skills_dir "$repo_root" "$harness")" || continue
    model_key="$(dotfiles_agent_harness_model_config_key "$repo_root" "$harness")" \
      || die "harness $harness has no model_config_key in agents/harnesses/$harness.yaml"
    config_path="$home_dir/$home_config"
    [[ -f "$config_path" ]] || continue

    model="$(configured_model_from_home_config "$config_path" "$model_key")" || continue
    model="$(dotfiles_agent_harness_normalize_model "$repo_root" "$harness" "$model")"
    selected_model="$(dotfiles_agent_harness_normalize_model "$repo_root" "$harness" "$target_model")"
    [[ -z "$target_model" || "$selected_model" == "$model" ]] || continue
    [[ -n "$skills_dir" ]] || continue

    dotfiles_agent_artifact_name "$harness" "$model"
  done
}

selected_artifacts_or_die() {
  local selected

  if [[ -n "$target_harness" && -n "$target_model" ]]; then
    dotfiles_agent_artifact_name \
      "$target_harness" \
      "$(dotfiles_agent_harness_normalize_model "$repo_root" "$target_harness" "$target_model")"
    return
  fi

  selected="$(discovered_artifacts)"
  if [[ -n "$selected" ]]; then
    printf '%s\n' "$selected"
    return 0
  fi

  if [[ -n "$target_harness" ]]; then
    die "no configured model found for harness $target_harness under $home_dir (pass both --harness and --model to symlink an explicit target)"
  fi
  if [[ -n "$target_model" ]]; then
    die "no configured harness found for model $target_model under $home_dir (pass both --harness and --model to symlink an explicit target)"
  fi

  die "no harness/model targets discovered under $home_dir (pass --harness and --model to symlink an explicit target)"
}

relative_artifact_target_for_repo_home() {
  local artifact_skill_dir=$1
  local component
  local prefix='../'
  local skills_dir=$2

  IFS=/ read -r -a components <<<"$skills_dir"
  for component in "${components[@]}"; do
    [[ -n "$component" ]] || continue
    prefix="../$prefix"
  done

  printf '%s%s\n' "$prefix" "$(repo_relative "$artifact_skill_dir")"
}

symlink_target_for_artifact() {
  local artifact_skill_dir=$1
  local skills_dir=$2

  if [[ "$home_dir" == "$repo_root/home" ]]; then
    relative_artifact_target_for_repo_home "$artifact_skill_dir" "$skills_dir"
  else
    printf '%s\n' "$artifact_skill_dir"
  fi
}

ensure_skill_symlink() {
  local artifact=$1
  local artifact_skill_dir="$repo_root/agents/skills/artifacts/$artifact/skills/$skill"
  local current_target
  local harness
  local link_path
  local link_target
  local skills_dir

  harness="$(dotfiles_agent_artifact_harness "$artifact")" \
    || die "unsupported harness/model target: $artifact"
  dotfiles_agent_harness_is_known "$repo_root" "$harness" \
    || die "unsupported harness target: $harness"

  skills_dir="$(dotfiles_agent_harness_skills_dir "$repo_root" "$harness")" \
    || die "harness $harness has no skills_dir in agents/harnesses/$harness.yaml"
  [[ -d "$artifact_skill_dir" ]] \
    || die "missing runtime skill artifact: $(repo_relative "$artifact_skill_dir") (run update-skill.bash for this harness/model first)"

  link_path="$home_dir/$skills_dir/$skill"
  link_target="$(symlink_target_for_artifact "$artifact_skill_dir" "$skills_dir")"

  mkdir -p "$(dirname -- "$link_path")"
  if [[ -L "$link_path" ]]; then
    current_target="$(readlink "$link_path")"
    if [[ "$current_target" == "$link_target" ]]; then
      unchanged_count=$((unchanged_count + 1))
      log "  [ok] $skill -> $artifact"
      log "       $link_path -> $link_target"
      return 0
    fi
    rm "$link_path"
  elif [[ -e "$link_path" ]]; then
    die "refusing to replace non-symlink skill path: $link_path"
  fi

  ln -s "$link_target" "$link_path"
  linked_count=$((linked_count + 1))
  log "  [link] $skill -> $artifact"
  log "         $link_path -> $link_target"
}

home_dir="$repo_root/home"
requested_skill=''
skill=''
skill_source_relpath=''
target_harness=''
target_model=''
verbose=0
linked_count=0
unchanged_count=0

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

home_dir="$(absolute_path "$home_dir")"
[[ -d "$home_dir" ]] || die "home directory does not exist: $home_dir"

validate_target_filters
configure_skill "$requested_skill"

selected_artifacts="$(selected_artifacts_or_die)"
if [[ "${DOTFILES_AGENT_SYMLINK_NO_SUMMARY:-0}" != 1 ]]; then
  log "Symlinking skill: $skill"
  log "Home: $home_dir"
  verbose_log "Source: agents/skills/src/$skill_source_relpath"
fi

while IFS= read -r artifact; do
  [[ -n "$artifact" ]] || continue
  ensure_skill_symlink "$artifact"
done <<<"$selected_artifacts"

if [[ "${DOTFILES_AGENT_SYMLINK_NO_SUMMARY:-0}" != 1 ]]; then
  log "Done: $linked_count linked, $unchanged_count already correct."
fi
