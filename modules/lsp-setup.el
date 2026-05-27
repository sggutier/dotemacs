;;; lsp-setup.el --- LSP, snippets, and diagnostics -*- lexical-binding: t -*-

;;; Snippets

;; yasnippet must be loaded before lsp-bridge because lsp-bridge's
;; completion backend (acm) uses it for snippet expansion.
(use-package yasnippet
  :ensure '(:host github :repo "joaotavora/yasnippet"
                  :ref "c1e6ff23e9af16b856c88dfaab9d3ad7b746ad37" :pin t)
  :init
  (yas-global-mode 1))

;;; LSP client

;; lsp-bridge is a fast, Python-backed LSP client.  Unlike lsp-mode/eglot
;; it manages language server processes in a Python subprocess and
;; communicates via JSONRPC from there, so large responses never block
;; the Emacs main thread.
;;
;; :build (:not elpaca--byte-compile) is required because lsp-bridge
;; ships Python files that must not be byte-compiled by Emacs.
(use-package lsp-bridge
  :ensure '(:host github :repo "manateelazycat/lsp-bridge"
                  :ref "755b36125821c6e601a69f8261c44d86b203379a" :pin t
                  :files (:defaults "*.el" "*.py" "acm" "core"
                                    "langserver" "multiserver" "resources")
                  :build (:not elpaca--byte-compile))
  :bind
  (("M-."     . lsp-bridge-find-def)
   ("M-,"     . lsp-bridge-find-def-return)
   ("C-c c k" . lsp-bridge-find-type-def)
   ("C-c c r" . lsp-bridge-rename)
   ("C-c c a" . lsp-bridge-code-action)
   ("C-c c n" . lsp-bridge-diagnostic-jump-next)
   ("C-c c p" . lsp-bridge-diagnostic-jump-prev))
  :init
  (global-lsp-bridge-mode))

;;; Terminal completion popup

;; acm-terminal renders lsp-bridge's completion popup in terminal
;; Emacs using popon (a floating window emulation layer).  Only
;; needed in non-graphical sessions; graphical Emacs uses its own
;; child-frame popup.
(unless (display-graphic-p)
  (use-package popon
    :ensure '(:host nil :repo "https://codeberg.org/akib/emacs-popon.git"
                    :ref "bf8174cb7e6e8fe0fe91afe6b01b6562c4dc39da" :pin t))
  (use-package acm-terminal
    :ensure '(:host github :repo "twlz0ne/acm-terminal"
                    :ref "1851d8fa2a27d3fd8deeeb29cd21c3002b8351ba" :pin t)))

;;; Diagnostics

;; flycheck: on-the-fly syntax checking with fringe indicators.
;; Complements lsp-bridge diagnostics with checker-specific feedback.
(use-package flycheck
  :ensure '(:host github :repo "flycheck/flycheck"
                  :ref "0e5eb8300d32fd562724216c19eaf199ee1451ab" :pin t)
  :init (global-flycheck-mode))

(provide 'lsp-setup)
;;; lsp-setup.el ends here
