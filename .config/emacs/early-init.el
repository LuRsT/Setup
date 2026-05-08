;;; early-init.el -*- lexical-binding: t; -*-

;; Raise GC threshold during startup; init.el lowers it once startup finishes.
(setq gc-cons-threshold most-positive-fixnum)

;; We call `package-initialize' explicitly in init.el.
(setq package-enable-at-startup nil)

;; Disable UI chrome before the frame is drawn (avoids a brief flash).
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Don't resize the frame when font / mode-line changes height.
(setq frame-inhibit-implied-resize t)
