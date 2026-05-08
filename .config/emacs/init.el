;;; init.el -*- lexical-binding: t; -*-

;; Personal Emacs config — Doom-like feel without the bloat.
;; Keybindings aligned with neovim where reasonable; see EMACS_PLAN.md.
;; UI chrome / GC / package init are handled in early-init.el.

;;;; Package management

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-always-ensure t)

;; Vendored / local code: NANO modules + custom helpers (e.g. harpoon).
(add-to-list 'load-path (expand-file-name "nano"   user-emacs-directory))
(add-to-list 'load-path (expand-file-name "custom" user-emacs-directory))

;; Move Custom-managed settings into a separate file so init.el stays clean.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

;;;; Basic settings

(setq dired-kill-when-opening-new-dired-buffer t
      x-select-enable-clipboard-manager nil    ; suppress "Saving clipboard..." on quit
      large-file-warning-threshold nil
      undo-limit 80000000
      inhibit-compacting-font-caches t
      backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 20
      kept-old-versions 5)

(setq-default tab-width 4
              uniquify-buffer-name-style 'forward
              window-combination-resize t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook  'display-line-numbers-mode)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;;; NANO theme + Cascadia font

(setq nano-font-family-monospaced  "Cascadia Code NF"
      nano-font-family-proportional "Cascadia Code NF"
      nano-font-size 12)

(require 'nano-layout)
(require 'nano-faces)
(require 'nano-theme)
(require 'nano-theme-dark)
(nano-theme-set-dark)
(call-interactively 'nano-refresh-theme)
(require 'nano-modeline)
(require 'nano-help)

;;;; Which-key (built-in since Emacs 29)

(use-package which-key
  :ensure nil
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

;;;; Evil

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-integration t
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-want-fine-undo t
        evil-search-module 'evil-search
        evil-symbol-word-search t)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-snipe
  :after evil
  :config
  (setq evil-snipe-scope 'buffer
        evil-snipe-enable-highlight t
        evil-snipe-enable-incremental-highlight t)
  (evil-snipe-mode 1)
  (evil-snipe-override-mode 1))

;;;; Ivy / Counsel / Swiper

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (setq ivy-height 8
        ivy-initial-inputs-alist nil
        ivy-re-builders-alist '((t . ivy--regex-fuzzy)))
  (ivy-mode 1))

(use-package swiper)

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-history)))

(use-package counsel-projectile :after (counsel projectile))

(require 'nano-counsel)   ; requires ivy; load order matters

;;;; Projectile

(use-package projectile
  :diminish projectile-mode
  :init
  (when (file-directory-p "~/dev")
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-completion-system 'ivy
        projectile-switch-project-action #'projectile-dired)
  :bind-keymap ("C-c p" . projectile-command-map)
  :config (projectile-mode))

;;;; Magit

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;;; Leader keymap (general) — aligned with neovim

(use-package general
  :config
  (general-override-mode 1)
  (general-create-definer my-leader-def
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC")

  ;; Swap ; and : in motion state — fewer shift presses for command mode.
  (general-define-key
   :states 'motion
   ";" 'evil-ex
   ":" 'evil-repeat-find-char)

  (my-leader-def
    "SPC" 'counsel-projectile-find-file
    "b"   'ibuffer
    "e"   'flymake-show-buffer-diagnostics
    "z"   'evil-toggle-fold

    ;; File / Find
    "f"   '(:ignore t :which-key "File/Find")
    "ff"  'counsel-projectile-find-file
    "fg"  'counsel-rg
    "fb"  'counsel-switch-buffer
    "fr"  'xref-find-references
    "fs"  'counsel-imenu
    "ft"  'neotree-toggle

    ;; Harpoon — moved from `f*` so `f*` can mirror nvim's File/Find.
    "h"   '(:ignore t :which-key "Harpoon")
    "ha"  'harpoon-add-file
    "ht"  'harpoon-toggle-file
    "h1"  'harpoon-go-to-1
    "h2"  'harpoon-go-to-2
    "h3"  'harpoon-go-to-3
    "h4"  'harpoon-go-to-4
    "h5"  'harpoon-go-to-5
    "h6"  'harpoon-go-to-6
    "h7"  'harpoon-go-to-7
    "h8"  'harpoon-go-to-8
    "h9"  'harpoon-go-to-9

    ;; Code (LSP via eglot)
    "c"   '(:ignore t :which-key "Code")
    "ca"  'eglot-code-actions
    "cr"  'eglot-rename
    "cf"  'eglot-format-buffer

    ;; Git
    "g"   '(:ignore t :which-key "Git")
    "gg"  'magit-status
    "gb"  'magit-blame
    "gl"  'magit-log

    ;; Vim config (renamed from `e*` — `<leader>e` is now diagnostic).
    "v"   '(:ignore t :which-key "Vim config")
    "vv"  (lambda () (interactive)
            (find-file (expand-file-name "init.el" user-emacs-directory)))

    ;; Org-mode
    "o"   '(:ignore t :which-key "Org-mode")
    "oo"  (lambda () (interactive) (find-file org-default-notes-file))
    "oa"  'org-agenda
    "oc"  'org-capture

    ;; Search
    "s"   '(:ignore t :which-key "Search")
    "sp"  'counsel-rg

    ;; Projectile (overlaps with `f*`; kept for muscle memory)
    "p"   '(:ignore t :which-key "Projectile")
    "pp"  'projectile-switch-project
    "pf"  'projectile-find-file
    "pg"  'grep-find))

;; Ctrl-P opens fuzzy file finder in normal state, matching nvim.
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-p") 'counsel-projectile-find-file))

;;;; Org

(setq org-directory "~/vimwiki"
      org-default-notes-file "~/vimwiki/Tasks.org"
      org-ellipsis " ▼ "
      browse-url-browser-function 'browse-url-generic
      browse-url-generic-program  "firefox")

(defun my/org-font-setup ()
  "Make org headings + variable-pitch coexist with fixed-pitch code blocks."
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 ()
                                  (compose-region (match-beginning 1)
                                                  (match-end 1) "•"))))))
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil
                        :font "Cantarell" :weight 'regular :height (cdr face)))
  (dolist (face '(org-block org-table org-formula org-code org-verbatim
                  org-special-keyword org-meta-line org-checkbox
                  line-number line-number-current-line))
    (set-face-attribute face nil :inherit 'fixed-pitch)))

(defun my/org-toggle-heading ()
  "Toggle visibility of the current Org heading without expanding children."
  (interactive)
  (when (org-at-heading-p)
    (if (org-fold-folded-p)
        (org-fold-show-entry)
      (org-fold-hide-subtree))))

(use-package org
  :ensure nil
  :hook ((org-mode . variable-pitch-mode)
         (org-mode . my/org-font-setup))
  :config
  (require 'org-tempo)
  (dolist (entry '(("sh" . "src shell")
                   ("el" . "src emacs-lisp")
                   ("py" . "src python")))
    (add-to-list 'org-structure-template-alist entry))
  (setq org-capture-templates
        '(("t" "New entry" entry (file "Tasks.org") "* TODO %?")
          ("T" "Task"      entry (file+headline "Tasks.org" "Misc") "* TODO %?")))
  (define-key org-mode-map (kbd "TAB") #'my/org-toggle-heading))

(use-package org-bullets :hook (org-mode . org-bullets-mode))

(use-package evil-org
  :after evil
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;;; LSP via eglot (built-in, replaces lsp-mode + lsp-ui)

(use-package eglot
  :ensure nil
  :hook ((python-mode python-ts-mode terraform-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref t))

;;;; Completion in code buffers

(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-minimum-prefix-length 2)
  (company-idle-delay 0.2)
  (company-selection-wrap-around t))

;;;; Major modes

(use-package python
  :ensure nil
  :hook (python-mode . (lambda ()
                         (setq-local indent-tabs-mode nil
                                     tab-width 4))))

(use-package terraform-mode
  :mode "\\.tf\\'"
  :hook (terraform-mode . terraform-format-on-save-mode)
  :custom (terraform-indent-level 2))

(use-package yaml-mode :mode "\\.ya?ml\\'")

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"        . markdown-mode)
         ("\\.markdown\\'"  . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package editorconfig :config (editorconfig-mode 1))

;;;; Ligatures (Cascadia / JetBrains-style)

(use-package ligature
  :hook (prog-mode . ligature-mode)
  :config
  (ligature-set-ligatures
   'prog-mode
   '("-|" "-~" "---" "-<<" "-<" "--" "->" "->>" "-->" "///" "/=" "/=="
     "/>" "//" "/*" "*>" "***" "*/" "<-" "<<-" "<=>" "<=" "<|" "<||"
     "<|||" "<|>" "<:" "<>" "<-<" "<<<" "<==" "<<=" "<=<" "<==>" "<-|"
     "<<" "<~>" "<=|" "<~~" "<~" "<$>" "<$" "<+>" "<+" "</>" "</" "<*"
     "<*>" "<->" "<!--" ":>" ":<" ":::" "::" ":?" ":?>" ":=" "::=" "=>>"
     "==>" "=/=" "=!=" "=>" "===" "=:=" "==" "!==" "!!" "!=" ">]" ">:"
     ">>-" ">>=" ">=>" ">>>" ">-" ">=" "&&&" "&&" "|||>" "||>" "|>" "|]"
     "|}" "|=>" "|->" "|=" "||-" "|-" "||=" "||" ".." ".?" ".=" ".-" "..<"
     "..." "+++" "+>" "++" "[||]" "[<" "[|" "{|" "??" "?." "?=" "?:" "##"
     "###" "####" "#[" "#{" "#=" "#!" "#:" "#_(" "#_" "#?" "#(" ";;" "_|_"
     "__" "~~" "~~>" "~>" "~-" "~@" "$>" "^=" "]#")))

;;;; Neotree

(use-package neotree
  :commands neotree-toggle
  :config
  (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
  (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
  (evil-define-key 'normal neotree-mode-map (kbd "q")   'neotree-hide)
  (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter))

;;;; Harpoon (vendored at custom/harpoon.el)

(use-package f)
(use-package hydra)
(require 'harpoon)

;;;; Lower GC threshold once startup is done (raised in early-init.el)

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))
