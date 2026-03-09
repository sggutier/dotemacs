;;; markdown.el --- Markdown and Sapling commit message editing -*- lexical-binding: t -*-

;; Disable lsp-bridge in buffers where it provides no value (commit
;; messages, docs).  Guarded with fboundp so this module works
;; regardless of whether lsp-setup is loaded.
(defun saulg/disable-lsp-bridge ()
  "Disable lsp-bridge-mode in the current buffer if it is active."
  (when (fboundp 'lsp-bridge-mode)
    (lsp-bridge-mode -1)))

(defun saulg/commit-sl-txt-modes ()
  "Configure a buffer for Sapling commit messages (.commits.sl.txt files)."
  (markdown-mode)
  (turn-on-auto-fill)
  (saulg/disable-lsp-bridge))

(defun saulg/readme-md-modes ()
  "Configure a buffer for README.md files (GitHub-Flavoured Markdown)."
  (gfm-mode)
  (turn-on-auto-fill)
  (saulg/disable-lsp-bridge))

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"                  . saulg/commit-sl-txt-modes)
         ("\\.commits\\.sl\\.txt\\'"  . saulg/commit-sl-txt-modes)
         ("README\\.md\\'"            . saulg/readme-md-modes))
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(provide 'markdown)
;;; markdown.el ends here
