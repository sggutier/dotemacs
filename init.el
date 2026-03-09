;;; init.el --- Main configuration -*- lexical-binding: t -*-

;;; Bootstrap — Elpaca package manager

;; The block below is the standard Elpaca installer snippet.
;; On the first run it clones the repo, byte-compiles it, and generates
;; autoloads.  On subsequent runs it simply adds the build directory to
;; load-path and loads the autoloads file.
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Enable use-package :ensure support for Elpaca.  After this, any
;; (use-package foo :ensure t) delegates installation to Elpaca.
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;; Load committed baseline defaults, then point Emacs' customize
;; system at a gitignored file for machine-specific overrides.
(load (expand-file-name "customs-defaults.el" user-emacs-directory) 'noerror)
(setq custom-file (expand-file-name "customs.el" user-emacs-directory))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

;;; Modules

;; Add the modules directory to load-path so each module can be loaded
;; with (require 'feature-name).
(add-to-list 'load-path (expand-file-name "modules/" user-emacs-directory))

(require 'workspaces)
(require 'lsp-setup)
(require 'lang-go)
(require 'org-setup)

;;; Core UX

;; use-package emacs :ensure nil targets built-in Emacs behaviour without
;; involving Elpaca.  Good for settings that must take effect before any
;; package-provided mode activates.
(use-package emacs
  :ensure nil
  :custom
  ;; TAB indents if the line needs it, completes otherwise.
  ;; Pairs naturally with corfu for in-buffer completion.
  (tab-always-indent 'complete)

  ;; Emacs 30+: stop ispell from offering completions in text-mode.
  ;; Use cape-dict if you want dictionary completion instead.
  (text-mode-ispell-word-completion nil)

  ;; Hide M-x commands that don't apply to the current mode.
  ;; Makes the command list much less noisy.
  (read-extended-command-predicate #'command-completion-default-include-p))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

;; Replace the default C-g with the smarter version above.
(define-key global-map [remap keyboard-quit] #'prot/keyboard-quit-dwim)

;; Accept y/n instead of typing out yes/no for confirmations.
(setopt use-short-answers t)

;; Show available key continuations after a prefix key (e.g. C-c).
(which-key-mode 1)

;; Auto-close brackets, quotes, and other paired delimiters.
(electric-pair-mode 1)

;; Scroll one line at a time rather than jumping half a screen.
(setq scroll-step 1)
(setq scroll-conservatively 30000)
(setq auto-window-vscroll nil)

;; Show line numbers in programming buffers.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Show the column number in the mode line.
(setq column-number-mode t)

;; C-x C-_ toggles commenting on the current line or region.
;; (C-x C-/ is the built-in binding; _ is more reachable on Dvorak.)
(keymap-global-set "C-x C-_" #'comment-line)

;; Always use spaces for indentation; never insert tab characters.
(setq-default indent-tabs-mode nil)

;; Enable mouse support when running inside a terminal emulator.
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; Redirect auto-save files to a dedicated subdirectory so they don't
;; scatter # files across source trees.
(let ((dir (file-name-concat user-emacs-directory "auto-save/")))
  (make-directory dir :parents)
  (setq auto-save-file-name-transforms `((".*" ,dir t))))

;; Silently strip trailing whitespace from modified lines on save.
(use-package ws-butler
  :ensure t
  :hook (prog-mode-hook . ws-butler-mode))

;;; UI — Theme and visual modes

;; A warm light theme with good contrast.
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-gruvbox-light t))

;; Distraction-free writing: narrows the buffer to a centred column
;; and hides UI chrome.  Activate per-buffer with M-x writeroom-mode.
(use-package writeroom-mode
  :ensure t)

;; Soft-wrap lines at a configurable column width and optionally centre
;; the text block.  Used standalone or as a visual component of org-present.
(use-package visual-fill-column
  :ensure t
  :custom
  (visual-fill-column-width 110)
  (visual-fill-column-center-text t))

;;; Completion

;; Vertico: minimal vertical completion UI for the minibuffer.
(use-package vertico
  :ensure '(:host github :repo "minad/vertico" :tag "2.0" :pin t)
  :init
  (vertico-mode))

;; Marginalia: adds annotations (file sizes, docstrings, keybindings,
;; etc.) to minibuffer completion candidates.
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;; Corfu: in-buffer completion popup, complementing vertico which
;; handles the minibuffer.
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode))

;; Orderless: match completion candidates by space-separated components
;; in any order.  "go buf" matches "switch-to-buffer", "find-go-file", etc.
;; Falls back to partial-completion for file paths so /u/s/e still
;; expands to /usr/share/emacs.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;;; File management

(use-package dired
  :ensure nil
  :init
  ;; dired-x provides extra commands including dired-omit-mode, which
  ;; hides uninteresting files.
  (require 'dired-x)
  :bind (:map dired-mode-map
              ;; 'h' toggles hiding of dot-files (mnemonic: hidden).
              ("h" . dired-omit-mode))
  :config
  ;; When dired-omit-mode is on, also hide dot-files in addition to
  ;; the default set of omitted extensions.
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\..+$")))

;; Show a live preview of the file at point in a side window.
(use-package dired-preview
  :ensure t
  :bind (:map dired-mode-map
              ("p" . dired-preview-mode)))

;; Reuse the current buffer when descending into a directory instead
;; of creating a new one.  Disabled by default for safety; re-enable here.
(put 'dired-find-alternate-file 'disabled nil)

;; Keep a list of recently visited files.
(recentf-mode t)
(keymap-global-set "C-c f r" #'recentf)

;;; Terminal

;; clipetty forwards Emacs kill-ring entries to the system clipboard
;; via terminal escape sequences (OSC 52).  Essential when running
;; Emacs inside tmux or a remote SSH session.
(use-package clipetty
  :ensure '(:host github :repo "spudlyo/clipetty"
                  :ref "01b39044b9b65fa4ea7d3166f8b1ffab6f740362" :pin t)
  :hook (elpaca-after-init-hook . global-clipetty-mode))

(defun saulg/find-next-vterm-number ()
  "Return the smallest positive integer N with no buffer named *vterm*<N>.
Scans existing buffers, collects numbers from names matching the
pattern *vterm*<N>, then returns the first positive integer absent
from that set."
  (let ((existing '())
        (regex "^\\*vterm\\*<\\([0-9]+\\)>\\'"))
    (dolist (buf (buffer-list))
      (let ((name (buffer-name buf)))
        (when (string-match regex name)
          (let ((n (string-to-number (match-string 1 name) 10)))
            (when (> n 0)
              (push n existing))))))
    (let ((next 1))
      (while (member next existing)
        (setq next (1+ next)))
      next)))

(defun saulg/vterm-new ()
  "Open a new vterm buffer, auto-numbering it to avoid name conflicts."
  (interactive)
  (vterm (saulg/find-next-vterm-number)))

(use-package vterm
  :ensure '(:host github :repo "akermu/emacs-libvterm"
                  :ref "056ad74653704bc353d8ec8ab52ac75267b7d373" :pin t)
  :commands vterm-mode
  :bind
  (("C-c ESC" . vterm-send-escape)
   ("C-c o t" . saulg/vterm-new))
  :config
  ;; Kill the buffer automatically when the shell process exits.
  (setq vterm-kill-buffer-on-exit t)
  ;; 5000 lines of scrollback instead of the default 1000.
  (setq vterm-max-scrollback 5000))

;; Local Variables:
;; no-byte-compile: t
;; no-native-compile: t
;; no-update-autoloads: t
;; End:
