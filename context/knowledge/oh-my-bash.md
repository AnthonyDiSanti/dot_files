# Oh My Bash comparison

- Source: https://github.com/ohmybash/oh-my-bash and local shallow checkout at commit `05e6d03` on 2026-04-24.
- Why it matters: useful reference for Bash interactive ergonomics while this repo keeps Bash stable and invests primarily in zsh.
- When to consult: before adding Bash-specific completion, history/readline, prompt, alias, or tool-integration behavior.

## Snapshot

Oh My Bash is a Bash framework with a module loader for `lib`, `plugins`, `aliases`, `completions`, and `themes`, plus custom override directories and an auto-update command. The inspected checkout had 33 plugins, 59 completion modules, 15 alias packs, and 84 themes.

This repo is intentionally smaller: POSIX shared shell policy in `home/.config/shell/`, Bash-specific startup in `home/.config/bash/`, zsh-specific interactive UX in `home/.config/zsh/`, repo-native symlink deployment from the literal `home/` tree, and `scripts/verify.sh` coverage. Bash currently gets XDG history placement, Git prompt/completion, the shared alias/function baseline, and a custom prompt.

## Useful ideas to selectively reuse

- Bash sensible defaults: `histappend`, `cmdhist`, and `lithist` are now enabled. Still consider `checkwinsize`, `completion-ignore-case`, `show-all-if-ambiguous`, `mark-symlinked-directories`, `magic-space`, and maybe prefix history search bindings.
- Command completion layer: prefer installed command/package-manager completion sources when available, with repo-managed vendored files as fallback where useful. Consider opt-in/command-detected completion for `chezmoi`, `gh`, `brew`, `docker`, `kubectl`, `tmux`, `uv`, and similar tools when they are installed.
- Navigation/tool integrations: `fzf --bash`, `zoxide init bash`, and a small directory bookmark/jump story are worth evaluating if Bash remains a common interactive shell.
- Man-page coloring and optional prompt delegation to tools like Starship may be useful only if enabled explicitly.

## Ideas to avoid

- Do not adopt Oh My Bash wholesale. Its installer rewrites `~/.bashrc`, its updater pulls from upstream, and the large module/theme surface conflicts with this repo's small, symlink-backed, auditable dotfiles model.
- Avoid loading large alias packs by default. This repo should keep aliases curated and predictable; Git shortcuts are better kept small or moved into Git config aliases when they are workflow-level.
- Avoid broad behavior changes such as default `noclobber`, `autocd`, `cdspell`, `CDPATH`, or `sudo` key bindings unless explicitly chosen; these are high-surprise in a personal dotfiles baseline.
