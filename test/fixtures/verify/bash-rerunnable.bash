old_path=$PATH
old_prompt_command=${PROMPT_COMMAND:-}

# Bash interactive login startup enters through .bash_profile, which cascades here.
source "$HOME/.bash_profile"
[[ "$PATH" == "$old_path" ]]
[[ "${PROMPT_COMMAND:-}" == "$old_prompt_command" ]]

source "$HOME/.bash_profile"
[[ "$PATH" == "$old_path" ]]
[[ "${PROMPT_COMMAND:-}" == "$old_prompt_command" ]]
