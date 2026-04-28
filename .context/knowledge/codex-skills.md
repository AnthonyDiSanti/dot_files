# Codex skills

- Source: `agents/skills/`, `home/.codex/skills/`
- Why it matters: Codex skill discovery is sensitive to filesystem shape, and the repo may eventually expose the same skill sources to multiple agent harnesses.
- When to consult: adding, moving, or debugging a local Codex skill.
- Key points: Canonical shared skill sources live under `agents/skills/<skill>/`. Codex deployment paths live under `home/.codex/skills/` as real symlink nodes to those canonical directories, so bootstrap deploys `~/.codex/skills/<skill>` as a symlink to the repo symlink node. A fresh Codex prompt discovers a two-hop symlinked skill directory and reports the canonical `agents/skills/<skill>/SKILL.md` path.
- Gotchas: Codex did not discover the `commit-prep` skill when bootstrap symlinked only leaf files such as `~/.codex/skills/commit-prep/SKILL.md`. It did discover a regular skill directory, a symlinked skill directory, and the two-hop `~/.codex/skills/<skill> -> repo/home/.codex/skills/<skill> -> repo/agents/skills/<skill>` layout. Restart the Codex session after changing installed skill metadata.
- Verification: run `codex debug prompt-input 'test' | rg 'commit-prep|Available skills|skills/commit-prep' -C 2` after bootstrap or skill-shape changes.
