; (setq user-full-name "Gil")
; (setq user-mail-address "")

(setq nano-font-family-monospaced "JetBrains Mono")
(setq nano-font-family-proportional "JetBrains Mono")
(setq nano-font-size 14)


(setq org-directory "~/vimwiki")
(setq org-ellipsis " ▼ ")
(setq org-default-notes-file "~/vimwiki/Tasks.org")
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

(setq-default
 tab-width 4                                      ; Set width for tabs
 uniquify-buffer-name-style 'forward              ; Uniquify buffer names
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      inhibit-compacting-font-caches t            ; When there are lots of glyphs, keep them in memory
      )

;; Enable all JetBrains Mono ligatures in programming modes
(use-package ligature
:load-path "path-to-ligature-repo"
:config
(ligature-set-ligatures 'prog-mode '("-|" "-~" "---" "-<<" "-<" "--" "->" "->>" "-->" "///" "/=" "/=="
				    "/>" "//" "/*" "*>" "***" "*/" "<-" "<<-" "<=>" "<=" "<|" "<||"
				    "<|||" "<|>" "<:" "<>" "<-<" "<<<" "<==" "<<=" "<=<" "<==>" "<-|"
				    "<<" "<~>" "<=|" "<~~" "<~" "<$>" "<$" "<+>" "<+" "</>" "</" "<*"
				    "<*>" "<->" "<!--" ":>" ":<" ":::" "::" ":?" ":?>" ":=" "::=" "=>>"
				    "==>" "=/=" "=!=" "=>" "===" "=:=" "==" "!==" "!!" "!=" ">]" ">:"
				    ">>-" ">>=" ">=>" ">>>" ">-" ">=" "&&&" "&&" "|||>" "||>" "|>" "|]"
				    "|}" "|=>" "|->" "|=" "||-" "|-" "||=" "||" ".." ".?" ".=" ".-" "..<"
				    "..." "+++" "+>" "++" "[||]" "[<" "[|" "{|" "??" "?." "?=" "?:" "##"
				    "###" "####" "#[" "#{" "#=" "#!" "#:" "#_(" "#_" "#?" "#(" ";;" "_|_"
				    "__" "~~" "~~>" "~>" "~-" "~@" "$>" "^=" "]#"))
;; Enables ligature checks globally in all buffers. You can also do it
;; per mode with `ligature-mode'.
(global-ligature-mode t))

(use-package counsel :ensure t)

;; Load paths
(add-to-list 'load-path "~/.emacs.d/nano")
(add-to-list 'load-path "~/.emacs.d/custom") ; My own downloaded plugins

(require 'nano-layout)
(require 'nano-faces)
(require 'nano-theme)
(require 'nano-theme-dark)

(nano-theme-set-dark)
(call-interactively 'nano-refresh-theme)

(require 'nano-modeline)
(require 'nano-help)

(provide 'nano)

; Increase mini-frame size
(setq mini-frame-default-height 12)

(setq auto-save-file-name-transforms `((".", "~/.emacs-saves" t)))

(setq mini-frame-default-height 12)

;; Which key (file in 'custom' folder)
(require 'which-key)
(which-key-mode)

; Keep the time for which-key to open up short, because I need to
; read it 80% of the time.
(setq which-key-idle-delay 0.5)

;; Enable line numbers in coding mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Initialize package sources
(require 'package)

;; TODO: CHeck whether I need all these bellow
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                    ("org" . "https://orgmode.org/elpa/")
                    ("elpa" . "https://elpa.gnu.org/packages/")))

;(unless package-archive-contents
;  (package-refresh-contents))

(use-package command-log-mode :ensure t)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Ivy for completion and fuzzy
(use-package ivy
  :ensure t
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
  (ivy-mode 1))

;; number of lines in e.g. file-selector
(setq ivy-height 8)

; This config shows options by pressing `C-o` inside the search buffer.
(setq ivy-read-action-function #'ivy-hydra-read-action)

;; Had to move this here after ivy since it requires ivy
(require 'nano-counsel)


;; Remove toolbar and menubar and scroll-bar
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)


; Make Ivy Fuzzy
(setq ivy-re-builders-alist
      '((t . ivy--regex-fuzzy)))

;; Counsel
(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

(setq ivy-initial-inputs-alist nil)

;;;;;; Evil stuff
;; Configure evil

; Highlight search (this needs to be before require 'evil
(setq evil-search-module 'evil-search)

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))


(define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
(define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

;; General
(use-package general
  :ensure t)
(require 'general)

;; * Global Keybindings
;; `general-define-key' acts like `evil-define-key' when :states is specified
(general-define-key
 :states 'motion
 ;; swap ; and :
 ";" 'evil-ex
 ":" 'evil-repeat-find-char)
;; same as
(general-define-key
 :states 'motion
 ";" 'evil-ex
 ":" 'evil-repeat-find-char)
;; `general-def' can be used instead for `evil-global-set-key'-like syntax
(general-def 'motion
  ";" 'evil-ex
  ":" 'evil-repeat-find-char)

;; alternative using `general-translate-key'
;; swap ; and : in `evil-motion-state-map'
(general-swap-key nil 'motion
  ";" ":")

;; * Mode Keybindings
(general-define-key
 :states 'normal
 :keymaps 'emacs-lisp-mode-map
 ;; or xref equivalent
 "K" 'elisp-slime-nav-describe-elisp-thing-at-point)
;; `general-def' can be used instead for `evil-define-key'-like syntax
(general-def 'normal emacs-lisp-mode-map
  "K" 'elisp-slime-nav-describe-elisp-thing-at-point)

;; * Prefix Keybindings
;; :prefix can be used to prevent redundant specification of prefix keys
;; again, variables are not necessary and likely not useful if you are only
;; using a definer created with `general-create-definer' for the prefixes
;; (defconst my-leader "SPC")
;; (defconst my-local-leader "SPC m")

(general-create-definer my-leader-def
  ;; :prefix my-leader
  :prefix "SPC")

(general-create-definer my-local-leader-def
  ;; :prefix my-local-leader
  :prefix "SPC m")

;; ** Global Keybindings
(my-leader-def
  :keymaps 'normal
  ;; bind "SPC a"
  "oa" 'org-agenda
  "oc" 'org-capture
  "g" 'magit-status
  "b" 'ibuffer
  ;"p Menu
  "pp" 'projectile-switch-project
  "pf" 'projectile-find-file
  "pg" 'grep-find
)

;; * Settings
;; change evil's search module after evil has been loaded (`setq' will not work)
(general-setq evil-search-module 'evil-search)

;; Evil-org-mode
(use-package evil-org :ensure t)
(add-to-list 'load-path "~/.emacs.d/plugins/evil-org-mode")
(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar))

;; Make TAB work for toggle only
(defun my/org-cycle-only-current-subtree ()
  "Cycle the visibility of the current subtree only."
  (interactive)
  (org-narrow-to-subtree)
  (org-cycle)
  (widen))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "TAB") 'my/org-cycle-only-current-subtree))



(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Stop saving clipboard
(setq x-select-enable-clipboard-manager nil)


;; Magit stuff
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Projectile
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/dev")
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

;; NeoTreE
(use-package neotree :ensure t)
(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)


;; YAML
(use-package yaml :ensure t)

;; Markdown
(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; EditorConfig
(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; Find Dired
(require 'find-dired)
(setq find-ls-option '("-exec ls -ldh {} +" . "-ldh"))

;; Company
(use-package company
  :ensure t)
;; TODO: Check the backends I could find useful

;; Flycheck
(use-package flycheck
  :ensure t)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(yaml flycheck company company-mode terraform-mode ligature neotree which-key counsel-projectile projectile magit evil-collection command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
