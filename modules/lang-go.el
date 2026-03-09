;;; lang-go.el --- Go, Protobuf, YAML, and Bazel support -*- lexical-binding: t -*-

;; Sapling utilities (project-root, fixer-command, etc.) are a hard
;; dependency since we use them for project-relative paths.
(require 'sapling)

;;; Code formatter

;; reformatter.el generates a minor mode that runs a formatter on
;; buffer save.  goimports is preferred over plain gofmt because it
;; also manages import statements automatically.
(use-package reformatter
  :ensure t
  :config
  (reformatter-define go-format
    :program "goimports"
    :args '("/dev/stdin")))

;;; Tree-sitter language modes

;; treesit-auto installs tree-sitter grammars on demand and
;; transparently replaces legacy foo-mode with foo-ts-mode where a
;; grammar is available.
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install t)
  (treesit-auto-langs '(go yaml bash proto))
  :config
  (treesit-auto-install-all)
  (global-treesit-auto-mode)

  (use-package go-ts-mode
    :custom
    (go-ts-mode-indent-offset 4)
    :init
    (add-to-list 'auto-mode-alist '("\\.go\\'"     . go-ts-mode))
    (add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-ts-mode)))

  (use-package protobuf-ts-mode
    :ensure t
    :init
    (add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-ts-mode))))

(use-package yaml-pro
  :ensure t)

;;; Build system

(use-package bazel
  :ensure t)

(provide 'lang-go)
;;; lang-go.el ends here
