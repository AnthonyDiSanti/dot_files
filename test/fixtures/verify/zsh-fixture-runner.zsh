setopt ERR_EXIT

# Source each assertion fixture after interactive login startup has completed.
for fixture_name do
  DOTFILES_VERIFY_FIXTURE="$DOTFILES_VERIFY_FIXTURE_ROOT/$fixture_name"
  export DOTFILES_VERIFY_FIXTURE
  source "$DOTFILES_VERIFY_FIXTURE"
done
