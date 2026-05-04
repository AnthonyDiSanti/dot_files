# Knowledge Base

Curated notes that reduce repeated setup or debugging for this dotfiles repo. Keep this index short and link to deeper topic files.

## How to use
- Add a topic file when a note grows beyond ~20 lines or needs structure.
- Keep each topic focused and link to it from this index.
- Put repeatedly useful third-party, vendor, and agent-workflow notes into focused topic files under `knowledge/`.
- Keep `knowledge/` concise and retrieval-oriented. If the content becomes stable end-user or code-adjacent guidance, move it into the nearest durable project doc and leave a short breadcrumb here instead of duplicating it.

## Notes
- Keep short, cross-cutting notes here; promote them to a topic file once they grow.

## Topics
- [Bootstrap & symlinks](bootstrap.md) — repo-native home-tree bootstrap, managed-path state, and symlink behavior.
- [Agent instructions](agent-instructions.md) — skills, prompt-guide notes, and model-specific instruction tuning.
- [Agent reference submodules](agent-reference-submodules.md) — optional pinned vendor source/example trees under `agents/official-docs/`.
- [Claude Code](claude-code.md) — skill discovery paths, settings, and current Opus 4.6 pin.
- [Codex skills](codex-skills.md) — local skill source layout, symlink deployment, and discovery gotchas.
- [Cursor Agent](cursor-agent.md) — skill discovery path, stateful CLI config boundary, and Composer 2 Fast artifact target.
- [Gemini CLI](gemini-cli.md) — optional Gemini CLI docs submodule, managed settings, and pending harness bring-up references.
- [Codex approval rules](codex-rules.md) — rule-file locations, generated vs curated rules, and testing commands.
- [Shell initialization and shared functions](shell-init.md) — PATH, prompt, and shared shell helpers.
- [Oh My Bash comparison](oh-my-bash.md) — selective Bash ergonomics worth considering without adopting the framework.
- [Clipboard integration](clipboard.md) — Vim/zsh/tmux clipboard plan and provider stance.
- [Tmux configuration](tmux.md) — terminal capabilities, vi prompt/copy-mode keys, cwd-preserving splits, and editor support.
- [Zsh vi mode](zsh-vi-mode.md) — native ZLE vi-mode widgets, text objects, surround, and plugin inspiration.
- [Vim plugins (vim-plug)](vim.md) — tracked loader snapshot, local `plugged/`, Solarized 8 / truecolor, Mundo/python3.
- [Solarized assets](solarized.md) — no vendored `settings/solarized`; where Vim vs other apps get colors.
- [macOS defaults scripts](macos-defaults.md) — system UI defaults via `defaults`.
- [macOS keybindings](macos-keybindings.md) — Cocoa text field navigation bindings.
