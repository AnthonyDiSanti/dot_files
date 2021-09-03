# Exits a script if the previous command returned an error.  Exits with the same value the previous command returned.
exit_if_error () {
  RetCode=$?
  if [[ $RetCode -ne 0 ]]; then
    exit $RetCode
  else
    return 0
  fi
}
