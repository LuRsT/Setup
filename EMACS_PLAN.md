# Emacs config cleanup plan

## Context

- I (Gil) primarily use **neovim**. Emacs is kept for **org-mode** mostly, but I want
  to keep the option of using it for code (Python + LSP) as well.
- Two emacs configs currently coexist in this repo:
  - `.config/doom/` — old Doom Emacs config. **No longer used.**
  - `.config/emacs/` — vanilla Emacs config built around NANO modules. **This is
    the one I use.**
- The original goal of `.config/emacs/` was "Doom-like experience without the
  bloat". The current state has drifted: there are real bugs, dead code,
  duplicated bindings, and stale literate config. This plan fixes that.

## Goals

1. Delete `.config/doom/` entirely.
2. Slim and fix `.config/emacs/init.el` while keeping the Doom-like feel:
   evil, leader key (SPC), which-key, ivy/counsel, magit, org with bullets,
   LSP for Python.
3. Stay on **NANO theme** with **Cascadia Code NF** font.
4. Switch `lsp-mode` + `lsp-ui` → built-in `eglot`.
5. Keep harpoon (vim-style file marks).
6. Keep neotree, with proper shortcuts.
7. Add a real `early-init.el` so the existing comments stop lying about it.

## Definite fixes (real bugs / dead code in `init.el`)

1. **Add `early-init.el`**: disable UI early (tool-bar, menu-bar, scroll-bar),
   raise `gc-cons-threshold` to `most-positive-fixnum`, set
   `package-enable-at-startup nil`. The existing comment at `init.el:584`
   already references this file as if it exists.
2. **Remove the auto-tangle hook** (`init.el:469-476`): `config.org` is marked
   "NOT BEING USED ATM" but the hook still tangles it over `init.el` if the
   file is ever saved. Real footgun.
3. **Delete `config.org`** entirely — stale, never-used literate config.
4. **Wire up `efs/org-font-setup`** to `org-mode-hook` (it's defined at
   `init.el:439` and never called). Or delete it. Decision: wire it up — it's
   the org prettification we actually want.
5. **Move `evil-want-fine-undo` into evil's `:init` block** (currently set at
   `init.el:64` before evil loads — no effect).
6. **Remove the triplicated `;`/`:` swap** at `init.el:245-263` — three forms
   of the same binding copied from general.el's docs. Keep one.
7. **Remove duplicate `mini-frame-default-height`** (lines 87 and 91); the
   `mini-frame` package isn't even required, so drop both.
8. **Remove `(custom-set-variables '(package-selected-packages nil))`** at
   `init.el:590-595` — this tells `package-autoremove` everything is removable.
9. **Move `(provide 'nano)`** out of `init.el` — `provide` belongs in the file
   matching the feature, not in the config that requires it.
10. **Delete `.config/doom/`** (3 files: `init.el`, `config.org`, `packages.el`).

## Quality improvements

- **Wrap `general` in `use-package`** instead of bare `require` (consistency
  with the rest of the file).
- **Set `(setq use-package-always-ensure t)`** at the top — drops ~15
  repetitions of `:ensure t`.
- **Switch `lsp-mode` + `lsp-ui` → `eglot`**:
  - Eglot is built-in since Emacs 29.
  - Same LSP servers work (pylsp, pyright, terraform-ls).
  - Diagnostics via flymake; hover info via eldoc in echo area.
  - Lose `lsp-ui`'s sideline + doc-frame — acceptable for Python-only use.
- **Drop `command-log-mode`** — unused, no binding invokes it.
- **Drop `find-dired` `require`** — only sets `find-ls-option`, never used.
- **Drop `highlight-indentation`** — only used by yaml-mode hook; not worth
  the dependency. (Re-add if YAML editing in emacs becomes a thing.)
- **Prune `nano/`** to the 7 files actually `require`d:
  - keep: `nano-layout`, `nano-faces`, `nano-theme`, `nano-theme-dark`,
    `nano-modeline`, `nano-help`, `nano-counsel`
  - delete: `nano-agenda`, `nano-base-colors`, `nano-colors`, `nano-command`,
    `nano-compact`, `nano-defaults`, `nano-minibuffer`, `nano-mu4e`,
    `nano-session`, `nano-splash`, `nano-theme-light`, `nano-writer`,
    `nano-writer.org`, `quick-help.org`, `smex.el`

## Decisions (confirmed with user)

| Topic            | Decision                                                  |
| ---------------- | --------------------------------------------------------- |
| Doom config      | Delete `.config/doom/` entirely                           |
| Theme            | Keep NANO theme                                           |
| Font             | Cascadia Code NF (already set; ligatures stay as-is)      |
| Harpoon          | Keep — vendored at `custom/harpoon.el` (not on MELPA)     |
| Neotree          | Keep — bound under `<leader>ft` to match nvim             |
| LSP              | Switch from `lsp-mode` + `lsp-ui` → `eglot`               |
| Python           | Stay; eglot picks up pylsp / pyright automatically        |
| Markdown         | Keep `markdown-mode` (occasional MD edits in emacs)       |
| Terraform        | Keep `terraform-mode`; eglot picks up `terraform-ls`      |
| YAML             | Keep `yaml-mode`; drop `highlight-indentation` dep        |
| Code editing     | Stay supported (eglot + flymake + company)                |
| Keybindings      | Align with neovim where reasonable — see section below    |

## Keybinding parity with neovim

Goal: same muscle memory in both editors. nvim is the reference (since I use it
more); emacs adapts to match.

### Already aligned (no change)

- Leader = `SPC` in both
- `;` → `:` (command mode)
- `C-h` / `C-j` / `C-k` / `C-l` window navigation
- Vim motions (`hjkl`, `w`, `b`, `gg`, `G`, `/`, `?`, etc.) — via evil
- `gd` go to definition, `K` hover doc — eglot + evil-collection bind these

### Conflicts being resolved

1. **`<leader>f` prefix** — nvim uses it for File/Find; emacs currently uses it
   for harpoon. **Move harpoon to `<leader>h*`** (h = harpoon):
   - `<leader>ha` → harpoon add file (was `fa`)
   - `<leader>ht` → harpoon toggle UI (was `ft`)
   - `<leader>h1`–`<leader>h9` → jump to harpoon slot N (was `f1`–`f9`)

2. **`<leader>e`** — nvim uses bare `<leader>e` for "show diagnostic"; emacs
   currently uses `<leader>e` as a group prefix ("emacs stuff"). **Rename the
   emacs group to `<leader>v`** ("Vim config" — same as nvim):
   - `<leader>vv` → edit `init.el` (was `<leader>ee`)
   - `<leader>e` → `flymake-show-buffer-diagnostics` (free, matches nvim)

### New emacs bindings to add (mirror nvim)

| Binding         | Action                                          | nvim equivalent           |
| --------------- | ----------------------------------------------- | ------------------------- |
| `<leader>ff`    | `counsel-projectile-find-file`                  | Telescope find_files      |
| `<leader>fg`    | `counsel-rg`                                    | Telescope live_grep       |
| `<leader>fb`    | `counsel-switch-buffer`                         | Telescope buffers         |
| `<leader>ft`    | `neotree-toggle`                                | `<cmd>Neotree<CR>`        |
| `<leader>fr`    | `xref-find-references`                          | Telescope lsp_references  |
| `<leader>fs`    | `counsel-imenu`                                 | Telescope lsp_doc_symbols |
| `<leader>ca`    | `eglot-code-actions`                            | `vim.lsp.buf.code_action` |
| `<leader>cr`    | `eglot-rename`                                  | `vim.lsp.buf.rename`      |
| `<leader>cf`    | `eglot-format-buffer`                           | `vim.lsp.buf.format`      |
| `<leader>gl`    | `magit-log` (already bound — no change)         | Telescope git_commits     |
| `<leader>z`     | `evil-toggle-fold` / `org-cycle`                | `za`                      |
| `<C-p>`         | `counsel-projectile-find-file`                  | Telescope find_files      |

### Leader group names (which-key) — aligned

| Prefix          | Group name                                      |
| --------------- | ----------------------------------------------- |
| `<leader>f`     | File/Find                                       |
| `<leader>g`     | Git                                             |
| `<leader>c`     | Code                                            |
| `<leader>v`     | Vim config (renamed from "Emacs stuff")         |
| `<leader>h`     | Harpoon                                         |
| `<leader>o`     | Org-mode (emacs-only — no nvim equivalent)      |
| `<leader>s`     | Search (emacs-only)                             |
| `<leader>p`     | Projectile (emacs-only — could fold into `f`)   |
| `<leader>w`     | Windows (nvim-only currently — could add)       |

### Acceptable divergence

- `M-x`, `C-x C-f`, `C-c` etc. — emacs builtins. Coexist with leader-based
  bindings. Don't try to remove them.
- Mode-specific bindings injected by `evil-collection` (magit, dired, ibuffer)
  differ from nvim plugin equivalents (lazygit, oil). Acceptable — different
  plugins, different feel.
- `<leader>vv` opens `init.el` in emacs vs `init.lua` in nvim — semantically
  identical, target file naturally differs.

## What stays (Doom-like core)

- `evil` + `evil-collection` + `evil-snipe` + `evil-org`
- `general` (leader = `SPC`) + `which-key`
- `ivy` + `counsel` + `swiper` (fuzzy completion)
- `magit`
- `projectile` (could swap for built-in `project.el` later, not now)
- `org` + `org-bullets` + `org-tempo` + capture/agenda
- `company` (completion in prog-mode)
- `eglot` (replaces lsp-mode/lsp-ui)
- `editorconfig`
- `markdown-mode`, `yaml-mode`, `terraform-mode`, `python` mode
- NANO modules (the 7 actually used)
- `harpoon` (vendored, with hydra + f deps)
- `neotree`

## What goes

- All of `.config/doom/`
- `.config/emacs/config.org`
- `command-log-mode`
- `find-dired` require + `find-ls-option`
- `highlight-indentation` (and `custom/highlight-indentation.el` if vendored)
- `lsp-mode`, `lsp-ui` (replaced by eglot)
- 13 unused `nano/*.el` files

## Execution order (separate commits)

1. **`emacs: add early-init.el`** — UI off + GC raise + package-enable-at-startup nil.
2. **`emacs: rewrite init.el`** — slim, fixed, eglot-based, with bindings for
   neotree (`SPC o p`, `F8`). Keeps NANO + Cascadia + harpoon.
3. **`emacs: drop stale config.org`** — remove the file and its auto-tangle hook.
4. **`emacs: prune unused nano modules`** — delete the 13 unused files.
5. **`emacs: remove doom config`** — delete `.config/doom/` (3 files).

Each commit should leave emacs working — we won't ship a broken intermediate
state.

## Open questions / followups (post-cleanup, not blocking)

- **Add ThePrimeagen's harpoon to nvim** ([github](https://github.com/ThePrimeagen/harpoon)).
  Currently emacs has harpoon (vendored port) but nvim does not. Adding it
  would give truly identical bindings on both sides — `<leader>ha`/`ht`/`h1-9`
  in either editor. Install via lazy.nvim, configure with same leader keys.
- Consider replacing `projectile` with built-in `project.el`. Smaller
  dependency surface; integrates with eglot natively. Defer until after the
  cleanup lands.
- Consider replacing `ivy`/`counsel`/`swiper` with `vertico` + `consult` +
  `marginalia` + `orderless`. Modern stack, smaller, faster. Bigger change —
  separate plan.
- Consider `org-modern` instead of `org-bullets` for prettier org. Aesthetic.
- Consider tangling NANO sources from upstream rather than vendoring snapshots.
