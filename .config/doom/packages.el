;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! company-org-roam
   :recipe (:host github :repo "jethrokuan/company-org-roam"))

(package! helm-org-rifle
   :recipe (:host github :repo "alphapapa/org-rifle"))

(package! org-auto-tangle
  :recipe (:host github :repo "yilkalargaw/org-auto-tangle"))
