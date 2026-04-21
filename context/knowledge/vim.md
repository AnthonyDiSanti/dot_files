# Vim plugins (migrating to native packages)

- Source: `home/dot_vimrc`, `home/.vim/pack/` (target); legacy `home/.vim/bundle/` until removed.
- Why it matters: plugin layout and config must stay consistent for vanilla Vim over SSH.
- When to consult: adding/removing plugins, changing mappings, or bootstrap docs.
- Key points: Prefer Vim 8+ **packages** (`:help packages`)—`pack/*/start` for auto-loaded plugins, `pack/*/opt` + `packadd` when lazy-load is worth it. No Vundle.
- Planned / decided plugin line (see `context/decisions.md`): **ctrlpvim/ctrlp.vim**, **easymotion/vim-easymotion**, **simnalamburt/vim-mundo**, **preservim/nerdtree**, **preservim/nerdcommenter**; carry forward core tpope + solarized + textobj + tabular, etc.; drop language-specific plugins and **vim-capslock**.
- Gotchas: After removing a plugin, remove its maps, `g:` config, autocommands, and statusline calls—grep for plugin names and leader maps tied to them.
