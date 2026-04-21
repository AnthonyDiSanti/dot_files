# Exits a script if the previous command returned an error.  Exits with the same value the previous command returned.
exit_if_error () {
  local r=$?
  if (( r != 0 )); then
    exit "$r"
  fi
  return 0
}
