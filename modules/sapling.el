;;; sapling.el --- Sapling VCS utilities -*- lexical-binding: t -*-

;; Helpers for working with Sapling (sl) repositories.  `sl root'
;; also works in Git repos via Sapling's Git compatibility mode, so
;; these are usable in either context.

;;; Project root

(defun saulg/project-root ()
  "Return the root directory of the current Sapling/Git project."
  (string-trim (shell-command-to-string "sl root")))

;;; File path / URL helpers

(defun saulg/copy-file-url ()
  "Copy the current file's internal URL (relative to project root) to the kill ring.
The base URL is a placeholder; redefine or advise this function in
local.el to substitute your actual internal code-browser URL."
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

(provide 'sapling)
;;; sapling.el ends here
