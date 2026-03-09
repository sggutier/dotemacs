;;; lang-go.el --- Go, Protobuf, YAML, Bazel, and Sapling utilities -*- lexical-binding: t -*-

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
    (add-to-list 'auto-mode-alist '("\\.go\\'"   . go-ts-mode))
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

;;; Sapling VCS utilities

;; These helpers assume the project uses Sapling (sl) or Git and that
;; `sl root' returns the repository root.

(defun saulg/project-root ()
  "Return the root directory of the current Sapling/Git project."
  (string-trim (shell-command-to-string "sl root")))

(defun saulg/copy-file-url ()
  "Copy the current file's internal URL (relative to project root) to the kill ring.
The base URL is a placeholder; override this function in local.el to
substitute your actual internal code-browser URL."
  (interactive)
  (let* ((root (saulg/project-root))
         (relative-path (file-relative-name buffer-file-name root))
         (url (concat "mi-magical-url/" relative-path)))
    (kill-new url)
    (message "Copied: %s" url)))

(defun saulg/copy-file-relative-path ()
  "Copy the current file's path relative to the project root to the kill ring."
  (interactive)
  (let* ((root (saulg/project-root))
         (relative-path (file-relative-name buffer-file-name root)))
    (kill-new relative-path)
    (message "Copied: %s" relative-path)))

(keymap-global-set "C-c c u" #'saulg/copy-file-url)
(keymap-global-set "C-c c e" #'saulg/copy-file-relative-path)

;;; Go diagnostics helper

(defun saulg/fixer-command ()
  "Open a vterm buffer pre-loaded with a $GOPACKAGESDRIVER query.
Useful for diagnosing build issues in repos that use a custom
packages driver (e.g. a Bazel-backed one)."
  (interactive)
  (let ((relative-path (file-relative-name buffer-file-name (saulg/project-root))))
    (vterm (concat relative-path "-vterm"))
    (vterm-send-string (concat "echo {} | $GOPACKAGESDRIVER file=" relative-path))))

;;; Markdown — commit messages and documentation

(defun saulg/commit-sl-txt-modes ()
  "Configure a buffer for Sapling commit messages (.commits.sl.txt files)."
  (interactive)
  (markdown-mode)
  (turn-on-auto-fill)
  ;; No LSP server is useful in commit message buffers.
  (lsp-bridge-mode -1))

(defun saulg/readme-md-modes ()
  "Configure a buffer for README.md files (GitHub-Flavoured Markdown)."
  (interactive)
  (gfm-mode)
  (turn-on-auto-fill)
  (lsp-bridge-mode -1))

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"                   . saulg/commit-sl-txt-modes)
         ("\\.commits\\.sl\\.txt\\'"   . saulg/commit-sl-txt-modes)
         ("README\\.md\\'"             . saulg/readme-md-modes))
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(provide 'lang-go)
;;; lang-go.el ends here
