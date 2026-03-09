;;; workspaces.el --- Workspace isolation via persp-mode -*- lexical-binding: t -*-

;; persp-mode gives each named "perspective" its own buffer list.
;; This keeps projects separate: buffers opened while in the "work"
;; perspective won't appear in the "personal" one.

(defun saulg/persp-switch-buffer ()
  "`consult-buffer' scoped to the current perspective's buffer list."
  (interactive)
  (with-persp-buffer-list ()
    (consult-buffer)))

(defun saulg/persp-ibuffer (arg)
  "Open ibuffer scoped to the current perspective.
With a prefix ARG, open the full (unfiltered) ibuffer instead."
  (interactive "P")
  (if arg
      (ibuffer)
    (with-persp-buffer-list () (ibuffer arg))))

(use-package persp-mode
  :ensure '(:host github :repo "Bad-ptr/persp-mode.el"
                  :ref "124f4430008859a75b25521c474f37aa9f75afeb"
                  :pin t)
  :hook
  ;; Activate after the frame is fully set up to avoid interfering with
  ;; early-init display configuration.
  ((window-setup-hook . (lambda () (persp-mode 1)))
   ;; Filter *star-buffers* (*Messages*, *scratch*, etc.) out of
   ;; perspectives so they don't pollute per-workspace buffer lists.
   (persp-common-buffer-filter-functions
    . (lambda (b) (string-prefix-p "*" (buffer-name b)))))
  :bind
  (("C-x b"   . saulg/persp-switch-buffer)
   ("C-x C-b" . saulg/persp-ibuffer)
   ("C-c w N" . persp-add-new))
  :init
  (setq persp-keymap-prefix (kbd "C-c w"))
  ;; Disable the workspace-switch animation.
  (setq wg-morph-on nil)
  ;; Kill buffers that belong only to a perspective when that
  ;; perspective is closed.
  (setq persp-autokill-buffer-on-remove 'kill-weak)
  ;; Automatically add a buffer to the current perspective when its
  ;; major mode changes (e.g. when a file is first opened).
  (setq persp-add-buffer-on-after-change-major-mode t))

(provide 'workspaces)
;;; workspaces.el ends here
