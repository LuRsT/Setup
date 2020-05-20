;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 14))
(setq doom-font (font-spec :family "Hasklig" :size 13))
(if (string-match-p (regexp-quote "Hasklig")
    (aref (query-font (face-attribute 'default :font)) 0))
        (setq haskell-font-lock-symbols nil)
        (setq haskell-font-lock-symbols 'unicode))


;; (setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/vimwiki")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Remove the "Saving clipboard..." when closing emacs
(setq x-select-enable-clipboard-manager nil)

;; Keymappings for windows
; (map! :o "j" #'evilem-motion-next-visual-line
;       :o "k" #'evilem-motion-previous-visual-line)

;     windmove-up
;     windmove-down
;     windmove-left
;     windmove-right

; (map! :map global-map
;  "C-h" `,(+use-key-message doom-leader-key "h")
;  "C-s" `,(+use-key-message "/"))



(evil-snipe-mode -1)
(map! :nm "s" #'avy-goto-word-1
      :nm "S" #'avy-goto-char-timer)


; (after! pdf-tools
;   ;; open pdfs scaled to fit page
;   (setq-default pdf-view-display-size 'fit-width)
;   ;; automatically annotate highlights
;   (setq pdf-annot-activate-created-annotations t
;         pdf-view-resize-factor 1.1)
;    ;; faster motion
;   (map!
;    :map pdf-view-mode-map
;    (
;    :n "g g"          #'pdf-view-first-page
;    :n "G"            #'pdf-view-last-page
;    :n "E"            #'pdf-view-next-page-command
;    :n "N"            #'pdf-view-previous-page-command
;    :n "n"            #'evil-collection-pdf-view-previous-line-or-previous-page
;    :n "e"            #'evil-collection-pdf-view-next-line-or-next-page
;    :localleader
;       :prefix "o"
;         (:prefix "n"
;           :desc "Insert" "i" 'org-noter-insert-note
;           )
;    ))


(evil-set-initial-state 'term-mode 'emacs)

;; Org-Roam config
(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam)
  :init
  (setq org-roam-directory "/home/lurst/vimwiki/org-files/")
  (map! :leader
        :prefix "n"
        :desc "Org-Roam-Insert" "i" #'org-roam-insert
        :desc "Org-Roam-Find"   "/" #'org-roam-find-file
        :desc "Org-Roam-Buffer" "r" #'org-roam)
  :config
  (org-roam-mode +1))

;; From: https://www.ianjones.us/blog/2020-05-05-doom-emacs/
(after! org-roam
        (map! :leader
            :prefix "n"
            :desc "org-roam" "l" #'org-roam
            :desc "org-roam-insert" "i" #'org-roam-insert
            :desc "org-roam-switch-to-buffer" "b" #'org-roam-switch-to-buffer
            :desc "org-roam-find-file" "f" #'org-roam-find-file
            :desc "org-roam-show-graph" "g" #'org-roam-show-graph
            :desc "org-roam-insert" "i" #'org-roam-insert
            :desc "org-roam-capture" "c" #'org-roam-capture))


;; ;; Font exceptions
;; (plist-delete! +pretty-code-symbols :def)
;; (plist-delete! +pretty-code-symbols :in)
;; (plist-delete! +pretty-code-symbols :for)
;; (plist-delete! +pretty-code-symbols :lambda)
;; (plist-delete! +pretty-code-symbols :yield)
;; (plist-delete! +pretty-code-symbols :not-in)
;; (plist-delete! +pretty-code-symbols :and)
;; (plist-delete! +pretty-code-symbols :or)
;; (plist-put +pretty-code-symbols :|> #Xe142)
;; (plist-put +pretty-code-symbols :-> #Xe149)
;; (plist-put +pretty-code-symbols :=> #Xe161)
;; (plist-put +pretty-code-symbols :<- #Xe179)
;; (plist-put +pretty-code-symbols :<> #Xe1c9)
;; (plist-put +pretty-code-symbols :<!-- #Xe10e)
;; (plist-put +pretty-code-symbols :<!--- #Xe10f)


;; Shortcuts
;; SPC g g c a -> Git ammend
;; SPC f p     -> Edit config files
;;
;; Fix a problem with doom update
;; rm -rf ~/.emacs.d/.local/straight/repos/org-roam/

; (map! :nm "C-p" #'projectile-find-file)

;; While I'm learning emacs...
(after! which-key
  (setq which-key-idle-delay 0.5))

(map! :n "C-h"   #'evil-window-left
      :n "C-j"   #'evil-window-down
      :n "C-k"   #'evil-window-up
      :n "C-l"   #'evil-window-right)

(after! evil-ex
  (evil-ex-define-cmd "W" #'evil-write)
  (evil-ex-define-cmd "Wq" #'evil-quit-all)
  )
