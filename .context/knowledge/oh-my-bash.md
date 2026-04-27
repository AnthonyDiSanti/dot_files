# Oh My Bash comparison

- Source: https://github.com/ohmybash/oh-my-bash and local shallow checkout at commit `05e6d03` on 2026-04-24.
- Why it matters: useful reference for Bash interactive ergonomics while this repo keeps Bash stable and invests primarily in zsh.
- When to consult: before adding Bash-specific completion, history/readline, prompt, alias, or tool-integration behavior.

## Snapshot

Oh My Bash is a Bash framework with a module loader for `lib`, `plugins`, `aliases`, `completions`, and `themes`, plus custom override directories and an auto-update command. The inspected checkout had 33 plugins, 59 completion modules, 15 alias packs, and 84 themes.

This repo is intentionally smaller: POSIX shared shell policy in `home/.config/shell/`, Bash-specific startup in `home/.config/bash/`, zsh-specific interactive UX in `home/.config/zsh/`, repo-native symlink deployment from the literal `home/` tree, and `test/verify.sh` coverage. Bash currently gets XDG history placement, Git prompt/completion, the shared alias/function baseline, and a custom prompt.

## Useful ideas to selectively reuse

- Bash sensible defaults: `histappend`, `cmdhist`, `lithist`, `HISTTIMEFORMAT='%F %T '`, and `checkwinsize` are now enabled, along with prefix history search on Up/Down and case-/hyphen-insensitive completion matching. Still consider `show-all-if-ambiguous` and `mark-symlinked-directories` only if those behaviors are explicitly wanted.
- Command tool-support layer: prefer installed command/package-manager shell support when available. Git prompt helper discovery is shared POSIX policy, while Git bash-completion candidate ordering lives under `home/.config/bash/` for fallback use when no existing Git completion is registered. The old vendored `lib/git` fallback was removed. Consider command-detected support for installed tools such as `brew` and other CLIs with first-party generators.
- Navigation/tool integrations: fzf is now loaded from the installed `fzf --bash` / `fzf --zsh` generators when those options are supported. Still consider a small directory bookmark/jump story only if it fits the interactive workflow.
- Man-page coloring and optional prompt delegation to tools like Starship may be useful only if enabled explicitly.

## Review status

Implemented:
- Bash history preservation: enabled `shopt -s histappend cmdhist lithist`, added `HISTTIMEFORMAT='%F %T '`, and intentionally left `HISTCONTROL` unset. Zsh now stores timestamps/durations with `EXTENDED_HISTORY` and displays plain `history` through a compact wrapper around `fc -l -D -t '%F %T'`.
- Bash terminal resize support: enabled `checkwinsize` so Readline updates terminal dimensions after commands.
- Line-editor polish: Bash binds Up/Down to prefix history search and sets Readline case-insensitive completion plus `completion-map-case` where supported. Zsh binds Up/Down to `up-line-or-beginning-search` / `down-line-or-beginning-search`, keeps `Ctrl-R` useful through native reverse incremental history search when fzf is unavailable, uses native completion matcher styles for case-insensitive `-` / `_` matching, and trials `zsh/complist` menu selection plus colored grouped/described completion lists.
- Git helper source policy: removed the vendored `lib/git` submodule and now use helper files from the active Git install.
- Git helper abstraction boundary: shared POSIX functions own Git root and prompt-helper discovery; `home/.config/bash/git-completion.sh` owns Git bash-completion candidate ordering for fallback use; zsh consumes that helper only when it must configure an active-Git fallback because no native `_git` is already available.
- System completion source policy: Bash loads Homebrew or common system `bash-completion` frameworks when present and does not broadly source snippets without a framework. Git completion fallback runs only when `complete -p git` reports no existing Git completion; generated Bash completions check the same command-specific registration before installing. Zsh prepends Homebrew `share/zsh/site-functions` before `compinit`, adds active-Git fallback only when no `_git` is visible in `fpath`, and uses generated completions only when no `_comps[command]` entry exists. `codex`, `docker`, `gh`, `git-spice`, and `kubectl` have explicit command-generated fallbacks for non-package-manager installs. The `gs` alias is rebound to git-spice completion only when `gs` aliases `git-spice`, because zsh otherwise treats `gs` as Ghostscript. On Anthony's 2026-04-26 setup, Homebrew Bash, `bash-completion@2`, zsh, and tmux are installed; `/opt/homebrew/etc/bash_completion.d` and `/opt/homebrew/share/zsh/site-functions` contain formula/app-provided completion symlinks plus Homebrew's own `brew` completion. Some Bash snippets (`gh`, `docker`, `mas`, `npm`, `pnpm`) assume framework helpers such as `_get_comp_words_by_ref` or `_filedir`, so direct fallback sourcing is intentionally avoided. tmux and Vim do not get dotfiles fallbacks: tmux lacks a Docker-style first-party generator, Homebrew supplies Bash snippets, and zsh ships `_tmux` and `_vim`.
- fzf shell integration: Bash and zsh source the installed fzf generators from the shell-specific tool-support layer, with no repo-level opt-out. Older fzf builds that reject `--bash` / `--zsh` are skipped quietly, and the zsh wrapper filters the known upstream `can't change option: zle` restore warning while preserving other integration errors. Other command-generated completions follow the same principle: require the generator to succeed and emit non-empty shell code before evaluating it.

Discussed and deferred:
- `HISTIGNORE` / secret suppression: no default chosen; broad secret filtering is hard to make correct and can create false confidence.
- Prompt-time, immediate-write, or cross-session history syncing: intentionally not enabled because Anthony uses stable prompt history event numbers to rerun commands with `!num`. Avoid Bash `history -n` / `history -a`, zsh `INC_APPEND_HISTORY`, zsh `INC_APPEND_HISTORY_TIME`, and zsh `SHARE_HISTORY` unless that workflow is explicitly revisited.
- `history -p` and history expansion features such as `!prefix`, modifiers, and `:s/old/new/`: understood as user-facing Bash capabilities, but no config change needed.
- Readline/completion defaults such as `show-all-if-ambiguous` and `mark-symlinked-directories`: still candidates only after explicit behavior review.
- Additional command completions beyond the first system-first pass: still candidates when a tool lacks package-manager/native completions, with installed-command/package-manager sources preferred over vendored copies.
- Directory bookmark/jump helpers: still candidates only if they stay small and explicit.
- Clipboard helpers: defer for now. If simple `copyfile` / `copypath` helpers are added, prefer delegating text clipboard access to a maintained external CLI such as `clipboard-cli` when installed, or use a tiny macOS-only `pbcopy` path. Avoid owning a broad cross-platform clipboard backend matrix in this repo.
- Ghostty/macOS tab or split automation: skipped for now because the available OMZ-style helpers are osascript/UI-automation driven and likely brittle.

Dismissed:
- Adopting Oh My Bash wholesale.
- Loading broad alias packs by default.
- zoxide-style directory ranking/jump behavior.
- `HISTCONTROL=ignoredups`.
- Bash `magic-space`, `histverify`, and `histreedit` for now.
- OMZ `history-substring-search`, autosuggestions, syntax highlighting, autocomplete, and broad keybinding tables.
- High-surprise shell behavior defaults such as `noclobber`, `autocd`, `cdspell`, `CDPATH`, and sudo key bindings.

## Ideas to avoid

- Do not adopt Oh My Bash wholesale. Its installer rewrites `~/.bashrc`, its updater pulls from upstream, and the large module/theme surface conflicts with this repo's small, symlink-backed, auditable dotfiles model.
- Avoid loading large alias packs by default. This repo should keep aliases curated and predictable; Git shortcuts are better kept small or moved into Git config aliases when they are workflow-level.
- Avoid broad behavior changes such as default `noclobber`, `autocd`, `cdspell`, `CDPATH`, or `sudo` key bindings unless explicitly chosen; these are high-surprise in a personal dotfiles baseline.
