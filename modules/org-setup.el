;;; org-setup.el --- Org mode, journaling, and presentation -*- lexical-binding: t -*-

;;; Calendar

;; Start the week on Monday (ISO 8601).
(setq calendar-week-start-day 1)

;; Display ISO week numbers in the left margin of the calendar.
;; Uses calendar-iso-from-absolute to derive the week number from the
;; Gregorian date of the first day shown in each row.
(setq calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'font-lock-function-name-face))

;;; Org core

;; Default destination for org-capture notes.
(setq org-default-notes-file "~/org/capture.org")

;; Pull diary entries into the agenda view.
(setq org-agenda-include-diary t)

;; Two ways to open the capture interface: a key chord and a function key.
(keymap-global-set "C-c n r" #'org-capture)
(keymap-global-set "<f12>"   #'org-capture)

;;; Journal

(use-package org-journal
  :ensure t
  :defer t
  :init
  ;; Prefix key must be set before the package loads.
  (setq org-journal-prefix-key "C-c j ")
  :config
  (setq org-journal-file-type 'weekly)
  (setq org-journal-dir         "~/org/journal/"
        org-journal-date-format "%A, %d %B %Y"))

;;; Presentation

(defun saulg/org-present-prepare-slide (_buffer-name _heading)
  "Show only the current entry and its direct children."
  (org-overview)
  (org-show-entry)
  (org-show-children))

(defun saulg/org-present-start ()
  "Set up presentation visuals: larger fonts and centred text.
Relies on visual-fill-column-mode (configured in init.el)."
  (setq-local face-remapping-alist
              '((default              (:height 1.5  :family "ComicCode Nerd Font") default)
                (header-line          (:height 1.5  :family "ComicCode Nerd Font") header-line)
                (org-document-title   (:height 1.75 :family "ComicCode Nerd Font") org-document-title)
                (org-code             (:height 1.55) org-code)
                (org-verbatim         (:height 1.55) org-verbatim)
                (org-block            (:height 1.25) org-block)
                (org-block-begin-line (:height 0.7)  org-block)))
  ;; Use an empty header-line as top padding so the content doesn't
  ;; start at the very edge of the window.
  (setq header-line-format " ")
  (org-display-inline-images)
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(defun saulg/org-present-end ()
  "Tear down presentation visuals."
  (setq-local face-remapping-alist nil)
  (setq header-line-format nil)
  (org-remove-inline-images)
  (visual-fill-column-mode 0)
  (visual-line-mode 0))

(use-package org-present
  :ensure t
  :hook
  ((org-present-mode                    . saulg/org-present-start)
   (org-present-mode-quit               . saulg/org-present-end)
   (org-present-after-navigate-functions . saulg/org-present-prepare-slide)))

(provide 'org-setup)
;;; org-setup.el ends here
