# Bootstrap & symlinks (Puppet)

- Source: `bootstrap.sh`, `site.pp`
- Why it matters: defines which dotfiles are linked into `$HOME` and keeps the repo as the single source of truth.
- When to consult: adding/removing dotfiles or debugging missing config on a machine.
- Key points: `bootstrap.sh` sets `FACTER_home_dir` and `FACTER_dotfiles_dir`, then runs `puppet apply site.pp` to link dotfiles.
- Gotchas: Puppet must be installed; ensure target parent directories (for example `~/.codex`) exist on the machine.
