emulate -L zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

test_home="${1:?usage: zsh-vi-mode-operators.zsh HOME}"
fixture_dir="${0:A:h}"
child_fixture="$fixture_dir/zsh-vi-mode-operator-child.zsh"
zpty_name="dotfiles_zsh_vi_mode_operators_$$"
log_path="${TMPDIR:-/tmp}/dotfiles_zsh_vi_mode_operators_$$.log"

zmodload zsh/zpty

fail() {
  print -ru2 -- "zsh vi-mode operators: $*"
  exit 1
}

cleanup() {
  zpty -d "$zpty_name" 2>/dev/null || true
  rm -f "$log_path"
}

trap cleanup EXIT

read_until() {
  local pattern="$1" label="$2"
  local chunk seen="" zpty_status attempt

  for ((attempt = 0; attempt < 200; attempt++)); do
    if zpty -r -t "$zpty_name" chunk; then
      seen+="$chunk"
      [[ $seen == *"$pattern"* ]] && return 0
    else
      zpty_status=$?
      (( zpty_status == 2 )) && fail "$label exited early: ${(qqq)seen}"
    fi
    sleep 0.05
  done

  fail "timed out waiting for $label: ${(qqq)seen}"
}

start_child_shell() {
  local setup_command

  zpty -b "$zpty_name" \
    env \
    TERM=dumb \
    HOME="$test_home" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_STATE_HOME="$test_home/.local/state" \
    XDG_CACHE_HOME="$test_home/.cache" \
    zsh -f
  read_until '% ' "initial prompt"

  setup_command='source '"${(q)test_home}/.zshrc"'; '\
'DOTFILES_ZSH_VI_MODE_LOG='"${(q)log_path}"'; '\
'source '"${(q)child_fixture}"'; '\
'PROMPT="PROMPT> "; '\
'echo READY'
  zpty -w "$zpty_name" "$setup_command"
  read_until READY "configured zsh startup"
  read_until 'PROMPT> ' "configured prompt"
}

finish_child_shell() {
  zpty -w "$zpty_name" exit
  zpty -d "$zpty_name" 2>/dev/null || true
}

run_operator_case() {
  local name="$1" keys="$2" expected="$3"
  local dump_line

  print -r -- "CASE $name" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'echo abc'
  zpty -w -n "$zpty_name" $'\e'
  sleep 0.1
  zpty -w -n "$zpty_name" "$keys"
  sleep 0.1
  zpty -w -n "$zpty_name" Q
  read_until 'PROMPT> ' "$name dump"
  finish_child_shell

  dump_line="${${(f)"$(<"$log_path")"}[-1]}"
  [[ $dump_line == *"$expected"* ]] \
    || fail "$name expected $expected, got ${dump_line:-<no dump>}"
}

run_operator_case dae dae 'BUFFER="" CUT="echo abc"'
run_operator_case yae yae 'BUFFER="echo abc" CUT="echo abc"'
run_operator_case cae $'cae\e' 'BUFFER="" CUT="echo abc"'
