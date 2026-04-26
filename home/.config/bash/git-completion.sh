# Git's zsh completion wrapper also consumes Git's Bash completion script.
dotfiles_bash_git_completion_candidates() {
  while IFS= read -r dotfiles_git_share_root; do
    printf '%s\n' "$dotfiles_git_share_root/zsh/site-functions/git-completion.bash"
    printf '%s\n' "$dotfiles_git_share_root/git-core/git-completion.bash"
    printf '%s\n' "$dotfiles_git_share_root/bash-completion/completions/git"
  done <<EOF
$(dotfiles_git_share_roots)
EOF

  while IFS= read -r dotfiles_git_root; do
    printf '%s\n' "$dotfiles_git_root/etc/bash_completion.d/git-completion.bash"
  done <<EOF
$(dotfiles_git_prefix_roots)
EOF

  unset dotfiles_git_share_root dotfiles_git_root
}
