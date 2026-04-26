# Oh My Bash comparison

- Source: https://github.com/ohmybash/oh-my-bash and local shallow checkout at commit `05e6d03` on 2026-04-24.
- Why it matters: useful reference for Bash interactive ergonomics while this repo keeps Bash stable and invests primarily in zsh.
- When to consult: before adding Bash-specific completion, history/readline, prompt, alias, or tool-integration behavior.

## Snapshot

Oh My Bash is a Bash framework with a module loader for `lib`, `plugins`, `aliases`, `completions`, and `themes`, plus custom override directories and an auto-update command. The inspected checkout had 33 plugins, 59 completion modules, 15 alias packs, and 84 themes.

This repo is intentionally smaller: POSIX shared shell policy in `home/.config/shell/`, Bash-specific startup in `home/.config/bash/`, zsh-specific interactive UX in `home/.config/zsh/`, repo-native symlink deployment from the literal `home/` tree, and `test/verify.sh` coverage. Bash currently gets XDG history placement, Git prompt/completion, the shared alias/function baseline, and a custom prompt.

## Useful ideas to selectively reuse

- Bash sensible defaults: `histappend`, `cmdhist`, and `lithist` are now enabled. Still consider `checkwinsize`, `completion-ignore-case`, `show-all-if-ambiguous`, `mark-symlinked-directories`, `magic-space`, and maybe prefix history search bindings.
- Command completion layer: prefer installed command/package-manager completion sources when available. Git prompt helper discovery is shared POSIX policy, while Git bash-completion candidate ordering lives under `home/.config/bash/` and is explicitly consumed by zsh because upstream Git's zsh wrapper sources a matching bash completion script. The old vendored `lib/git` fallback was removed. Consider opt-in/command-detected completion for `gh`, `brew`, `docker`, `kubectl`, `tmux`, `uv`, and similar tools when they are installed.
- Navigation/tool integrations: `fzf --bash`, `zoxide init bash`, and a small directory bookmark/jump story are worth evaluating if Bash remains a common interactive shell.
- Man-page coloring and optional prompt delegation to tools like Starship may be useful only if enabled explicitly.

## Review status

Implemented:
- Bash history preservation: enabled `shopt -s histappend cmdhist lithist`.
- Git helper source policy: removed the vendored `lib/git` submodule and now use helper files from the active Git install.
- Git helper abstraction boundary: shared POSIX functions own Git root and prompt-helper discovery; `home/.config/bash/git-completion.sh` owns Git bash-completion candidate ordering; zsh explicitly consumes that helper because upstream Git's zsh wrapper depends on a bash completion script.

Discussed and deferred:
- `HISTTIMEFORMAT`: useful for timestamped history, but not yet pinned.
- `HISTIGNORE` / secret suppression: no default chosen; broad secret filtering is hard to make correct and can create false confidence.
- `history -n` / prompt-time history syncing: intentionally not enabled because it can move Bash event numbers under the history-number rerun workflow.
- `history -p` and history expansion features such as `!prefix`, modifiers, and `:s/old/new/`: understood as user-facing Bash capabilities, but no config change needed.
- Readline/completion defaults such as `completion-ignore-case`, `show-all-if-ambiguous`, `mark-symlinked-directories`, `magic-space`, and prefix history search bindings: still candidates for a later pass.
- Additional command completions for tools such as `gh`, `brew`, `docker`, `kubectl`, `tmux`, and `uv`: still candidates, with installed-command/package-manager sources preferred over vendored copies.
- Navigation/tool integrations such as `fzf`, `zoxide`, and directory bookmarks: still candidates, probably opt-in or command-detected.

Dismissed:
- Adopting Oh My Bash wholesale.
- Loading broad alias packs by default.
- High-surprise shell behavior defaults such as `noclobber`, `autocd`, `cdspell`, `CDPATH`, and sudo key bindings.

## Ideas to avoid

- Do not adopt Oh My Bash wholesale. Its installer rewrites `~/.bashrc`, its updater pulls from upstream, and the large module/theme surface conflicts with this repo's small, symlink-backed, auditable dotfiles model.
- Avoid loading large alias packs by default. This repo should keep aliases curated and predictable; Git shortcuts are better kept small or moved into Git config aliases when they are workflow-level.
- Avoid broad behavior changes such as default `noclobber`, `autocd`, `cdspell`, `CDPATH`, or `sudo` key bindings unless explicitly chosen; these are high-surprise in a personal dotfiles baseline.
