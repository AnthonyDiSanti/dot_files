# Bootstrap & symlinks (chezmoi)

- Source: `bootstrap.sh`, `.chezmoiroot`, `home/.chezmoi.toml.tmpl`
- Why it matters: defines which dotfiles are linked into `$HOME` and keeps the repo as the single source of truth.
- When to consult: adding/removing dotfiles or debugging missing config on a machine.
- Key points: `.chezmoiroot` makes `home/` the chezmoi source root; `home/.chezmoi.toml.tmpl` sets `mode = "symlink"`; `bootstrap.sh` runs `chezmoi --source "$repo" apply` and adds `--init` only when the config is missing or older than the template.
- Verification: run `scripts/verify.sh` after bootstrap or source-state changes.
- Gotchas: source names use chezmoi attributes (`dot_bash_profile` -> `~/.bash_profile`). `home/.vim` stays hidden and is linked by `home/symlink_dot_vim.tmpl` to preserve the existing whole-directory Vim behavior during the future Vim migration.
