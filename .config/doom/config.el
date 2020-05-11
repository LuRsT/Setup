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
