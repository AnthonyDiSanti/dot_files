emulate -L zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

test_home="${1:?usage: zsh-vi-mode-operators.zsh HOME}"
fixture_dir="${0:A:h}"
child_fixture="$fixture_dir/zsh-vi-mode-operator-child.zsh"
zpty_name="dotfiles_zsh_vi_mode_operators_$$"
log_path="${TMPDIR:-/tmp}/dotfiles_zsh_vi_mode_operators_$$.log"
fake_clipboard_file="${TMPDIR:-/tmp}/dotfiles_zsh_vi_mode_clipboard_$$"
clipboard_fixture_dir="$fixture_dir/fake-clipboard-unsupported"

zmodload zsh/zpty

fail() {
  print -ru2 -- "zsh vi-mode operators: $*"
  exit 1
}

cleanup() {
  zpty -d "$zpty_name" 2>/dev/null || true
  rm -f "$log_path" "$fake_clipboard_file"
}

settle_zle() {
  # Test shells lower KEYTIMEOUT, so short pauses are enough for Esc and ZLE input.
  sleep 0.03
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

wait_for_dump_line() {
  local label="$1"
  local attempt chunk zpty_status

  for ((attempt = 0; attempt < 200; attempt++)); do
    if ! zpty -r -t "$zpty_name" chunk; then
      zpty_status=$?
      (( zpty_status == 2 )) && fail "$label exited early before dump"
    fi
    dump_line="${${(f)"$(<"$log_path")"}[-1]}"
    [[ $dump_line == dump\ * ]] && return 0
    sleep 0.05
  done

  fail "timed out waiting for $label dump: ${dump_line:-<no log>}"
}

start_child_shell() {
  local child_path setup_command

  child_path="$clipboard_fixture_dir:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

  zpty -b "$zpty_name" \
    env \
    TERM=dumb \
    HOME="$test_home" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_STATE_HOME="$test_home/.local/state" \
    XDG_CACHE_HOME="$test_home/.cache" \
    DOTFILES_FAKE_CLIPBOARD_FILE="$fake_clipboard_file" \
    PATH="$child_path" \
    zsh -f
  read_until '% ' "initial prompt"

  setup_command='source '"${(q)test_home}/.zshrc"'; '\
'DOTFILES_ZSH_VI_MODE_LOG='"${(q)log_path}"'; '\
'KEYTIMEOUT=1; '\
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

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-unsupported"
  print -r -- "CASE $name" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'echo abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" "$keys"
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "$name"
  finish_child_shell

  [[ $dump_line == *"$expected"* ]] \
    || fail "$name expected $expected, got ${dump_line:-<no dump>}"
}

run_clipboard_yank_case() {
  local copied dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  rm -f "$fake_clipboard_file"
  print -r -- "CASE clipboard-yank" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'echo abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" yae
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "clipboard yank"
  finish_child_shell

  [[ $dump_line == *'BUFFER="echo abc" CUT="echo abc"'* ]] \
    || fail "clipboard yank expected native yank, got ${dump_line:-<no dump>}"
  [[ -r "$fake_clipboard_file" ]] || fail "clipboard yank did not write fake clipboard"
  copied="$(<"$fake_clipboard_file")"
  [[ $copied == 'echo abc' ]] || fail "clipboard yank copied ${(qqq)copied}"
}

run_clipboard_cut_case() {
  local name="$1" keys="$2" expected_clipboard="$3" expected_dump="$4"
  local copied dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  print -rn -- 'STALE' >"$fake_clipboard_file"
  print -r -- "CASE $name" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'echo abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" "$keys"
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "$name"
  finish_child_shell

  [[ $dump_line == *"$expected_dump"* ]] \
    || fail "$name expected $expected_dump, got ${dump_line:-<no dump>}"
  copied="$(<"$fake_clipboard_file")"
  [[ $copied == "$expected_clipboard" ]] \
    || fail "$name copied ${(qqq)copied}, expected ${(qqq)expected_clipboard}"
}

run_insert_backspace_case() {
  local copied dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  print -rn -- 'STALE' >"$fake_clipboard_file"
  print -r -- "CASE insert-backspace" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\177'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "insert backspace"
  finish_child_shell

  [[ $dump_line == *'BUFFER="ab"'* ]] \
    || fail "insert backspace expected BUFFER=\"ab\", got ${dump_line:-<no dump>}"
  copied="$(<"$fake_clipboard_file")"
  [[ $copied == STALE ]] \
    || fail "insert backspace copied ${(qqq)copied}, expected STALE"
}

run_mid_command_insert_backspace_case() {
  local copied dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  print -rn -- 'STALE' >"$fake_clipboard_file"
  print -r -- "CASE mid-command-insert-backspace" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" hi
  settle_zle
  zpty -w -n "$zpty_name" $'\177'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "mid-command insert backspace"
  finish_child_shell

  [[ $dump_line == *'BUFFER="bc"'* ]] \
    || fail "mid-command insert backspace expected BUFFER=\"bc\", got ${dump_line:-<no dump>}"
  copied="$(<"$fake_clipboard_file")"
  [[ $copied == STALE ]] \
    || fail "mid-command insert backspace copied ${(qqq)copied}, expected STALE"
}

run_mid_command_insert_delete_case() {
  local copied dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  print -rn -- 'STALE' >"$fake_clipboard_file"
  print -r -- "CASE mid-command-insert-delete" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" hi
  settle_zle
  zpty -w -n "$zpty_name" $'\e[3~'
  settle_zle
  zpty -w -n "$zpty_name" $'\e'
  settle_zle
  zpty -w -n "$zpty_name" Q
  wait_for_dump_line "mid-command insert delete"
  finish_child_shell

  [[ $dump_line == *'BUFFER="ac"'* ]] \
    || fail "mid-command insert delete expected BUFFER=\"ac\", got ${dump_line:-<no dump>}"
  copied="$(<"$fake_clipboard_file")"
  [[ $copied == STALE ]] \
    || fail "mid-command insert delete copied ${(qqq)copied}, expected STALE"
}

run_clipboard_load_case() {
  local dump_line

  clipboard_fixture_dir="$fixture_dir/fake-clipboard-supported"
  print -rn -- 'CLIP' >"$fake_clipboard_file"
  print -r -- "CASE clipboard-load" >>"$log_path"
  start_child_shell
  zpty -w -n "$zpty_name" 'echo abc'
  settle_zle
  zpty -w -n "$zpty_name" $'\a'
  settle_zle
  wait_for_dump_line "clipboard load"
  finish_child_shell

  [[ $dump_line == *'BUFFER="echo abc" CUT="CLIP"'* ]] \
    || fail "clipboard load expected CUT=\"CLIP\", got ${dump_line:-<no dump>}"
}

run_operator_case dae dae 'BUFFER="" CUT="echo abc"'
run_operator_case yae yae 'BUFFER="echo abc" CUT="echo abc"'
run_operator_case cae $'cae\e' 'BUFFER="" CUT="echo abc"'
run_clipboard_yank_case
run_clipboard_cut_case clipboard-delete dae 'echo abc' 'BUFFER="" CUT="echo abc"'
run_clipboard_cut_case clipboard-delete-char x c 'CUT="c"'
run_clipboard_cut_case clipboard-change $'cae\e' 'echo abc' 'BUFFER="" CUT="echo abc"'
run_clipboard_cut_case clipboard-substitute $'sX\e' c 'CUT="c"'
run_insert_backspace_case
run_mid_command_insert_backspace_case
run_mid_command_insert_delete_case
run_clipboard_load_case
