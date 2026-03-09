;;; early-init.el --- Early initialization -*- lexical-binding: t -*-

;; early-init.el is loaded before the package system and GUI are
;; initialized.  Anything that must happen before packages are loaded,
;; or that affects startup appearance, goes here.

;;; Package manager

;; Disable the built-in package.el.  We use Elpaca instead, which is
;; bootstrapped in init.el.
(setq package-enable-at-startup nil)

;;; Environment

;; lsp-bridge communicates with language servers via a Python subprocess.
;; Setting LSP_USE_PLISTS tells it to represent JSON objects as plists
;; rather than hash tables, which is significantly faster in Emacs Lisp.
(setenv "LSP_USE_PLISTS" "true")

;;; UI — suppress default chrome early

;; Disabling the toolbar and menu bar here (rather than in init.el)
;; prevents them from flickering into view during startup before being
;; hidden.
(tool-bar-mode -1)
(menu-bar-mode -1)

;;; Keyboard — Dvorak layout adjustment

;; On Dvorak, the physical key in the C-x position types 't', so we
;; swap C-x ↔ C-t at the translation layer.  Doing this in early-init
;; ensures it is in effect before any key bindings are established
;; elsewhere, avoiding ordering surprises.
(define-key key-translation-map [?\C-x] [?\C-t])
(define-key key-translation-map [?\C-t] [?\C-x])

;; Local Variables:
;; no-byte-compile: t
;; no-native-compile: t
;; no-update-autoloads: t
;; End:
