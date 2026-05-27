;;; lang-go.el --- Go, Protobuf, YAML, and Bazel support -*- lexical-binding: t -*-

;; Sapling utilities (project-root, fixer-command, etc.) are a hard
;; dependency since we use them for project-relative paths.
(require 'sapling)

;;; Code formatter

;; reformatter.el generates a minor mode that runs a formatter on
;; buffer save.  goimports is preferred over plain gofmt because it
;; also manages import statements automatically.
(use-package reformatter
  :ensure '(:host github :repo "purcell/emacs-reformatter"
                  :ref "c0ddac04b7b937ed56d6bf97e4bfcc4eccfa501a" :pin t)
  :config
  (reformatter-define go-format
    :program "goimports"
    :args '("/dev/stdin")))

;;; Tree-sitter language modes

;; treesit-auto installs tree-sitter grammars on demand and
;; transparently replaces legacy foo-mode with foo-ts-mode where a
;; grammar is available.
(use-package treesit-auto
  :ensure '(:host github :repo "renzmann/treesit-auto"
                  :ref "31466e4ccfd4f896ce3145c95c4c1f8b59d4bfdf" :pin t)
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
    :ensure '(:host github :repo "emacsattic/protobuf-ts-mode"
                    :ref "65152f5341ea4b3417390b3e60b195975161b8bc" :pin t)
    :init
    (add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-ts-mode))))

(use-package yaml-pro
  :ensure '(:host github :repo "zkry/yaml-pro"
                  :ref "9b9509188e5b88bb933e98ab36ab992519b9554b" :pin t))

;;; Build system

(use-package bazel
  :ensure '(:host github :repo "bazelbuild/emacs-bazel-mode"
                  :ref "f2a049758c4e04b0fa1765fe0dfee5fc240d4732" :pin t))

(provide 'lang-go)
;;; lang-go.el ends here
