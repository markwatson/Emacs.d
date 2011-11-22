;;
;; Mark's emacs file. Taken from a variety of sources.
;;

(message "Loading pure magic...")

;;;;;;;;;;;;;
;; Housework
;;;;;;;;;;;;;
; Fix delete key.  Not sure why it was broken on XEmacs for NT...
(setq delete-key-deletes-forward t)

(add-to-list 'load-path "~/.emacs.d")

;;;;;;;;;;;;;
;; Mods
;;;;;;;;;;;;;
;; snippets
(require 'yasnippet-bundle)

;; Turn on line numbers and clock display
(line-number-mode 1)
(column-number-mode 1)
(setq-default display-time 't)
(setq-default display-time-24hr-format 't)
(display-time)

(require 'paren)
(show-paren-mode t)
(setq-default show-paren-style 'mixed)

(put 'upcase-region 'disabled nil)

(setq kill-whole-line 1)
(setq make-backup-files nil)
(setq-default case-fold-search t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq transient-mark-mode t)

;; visible bell
(setq visible-bell nil)

;; allow selection deletion
(delete-selection-mode t)

;; make sure delete key is delete key
(global-set-key [delete] 'delete-char)

;; have emacs scroll line-by-line
(setq scroll-step 1)

;; You really don't need these; trust me.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; set color-theme
(require 'doremi-cmd)
(require 'color-theme)
;;(if (not window-system)
;;  (color-theme-twilight))
(if window-system
  (color-theme-clarity))
(if window-system
  (menu-bar-mode 1))

;; fonts
(set-default-font "Terminus")

;; you know you looking at a winner...
(when (fboundp 'winner-mode)
  (winner-mode 1))

(defun mouse-set-point-and-yank (event)
       "Sets the point at the mouse location, then yanks from Clipboard"
       (interactive "@e")
       (mouse-set-point event)
       (yank-clipboard-selection))

(defun my-trim-spaces-ateol-and-save ()
  "Trim trailing spaces at the end of every line in current buffer and save buffer."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (re-search-forward "[ \t]+$" nil t)
      (replace-match "" nil nil))
    (save-buffer)))
(define-key esc-map "s" 'my-trim-spaces-ateol-and-save)
(define-key global-map [\M-s]   'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-x\C-s" 'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-cs" 'my-trim-spaces-ateol-and-save)

;; Special cursor
;; Change cursor color according to mode; inspired by
;; http://www.emacswiki.org/emacs/ChangingCursorDynamically
(setq djcb-read-only-color       "gray")
;; valid values are t, nil, box, hollow, bar, (bar . WIDTH), hbar,
;; (hbar. HEIGHT); see the docs for set-cursor-type

(setq djcb-read-only-cursor-type 'hbar)
(setq djcb-overwrite-color       "red")
(setq djcb-overwrite-cursor-type 'box)
(setq djcb-normal-color          "yellow")
(setq djcb-normal-cursor-type    'bar)

(defun djcb-set-cursor-according-to-mode ()
  "change cursor color and type according to some minor modes."

  (cond
    (buffer-read-only
      (set-cursor-color djcb-read-only-color)
      (setq cursor-type djcb-read-only-cursor-type))
    (overwrite-mode
      (set-cursor-color djcb-overwrite-color)
      (setq cursor-type djcb-overwrite-cursor-type))
    (t
      (set-cursor-color djcb-normal-color)
      (setq cursor-type djcb-normal-cursor-type))))

(add-hook 'post-command-hook 'djcb-set-cursor-according-to-mode)


;;;;;;;;;;;;;;;;;
;; Load languages
;;;;;;;;;;;;;;;;;

;; IDO
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

;; haskell
;(load "~/.emacs.d/haskell/haskell-site-file")
;(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

; php mode
;(add-to-list 'load-path "~/.emacs.d/php-mode")
;(require 'php-mode)

;; Org Mode
(setq load-path (cons "~/.emacs.d/org/lisp" load-path))
(setq load-path (cons "~/.emacs.d/org/contrib/lisp" load-path))
(require 'org-install)

;; cperl-mode
(autoload 'perl-mode "cperl-mode"
  "alternate mode for editing Perl programs" t)
(setq auto-mode-alist (append '(("\\.[Pp][Llm][wW]?$" . cperl-mode)) auto-mode-alist))
(setq cperl-hairy t)
(add-hook 'cperl-mode-hook '(lambda () (setq cperl-indent-level 3
					    cperl-continued-statement-offset 3
					    cperl-continued-brace-offset -3
					    cperl-brace-offset 0
					    cperl-brace-imaginary-offset 0
					    cperl-label-offset -2
				       )))

;; Many modes loaded
(autoload 'php-mode    "php-mode"    "PHP editing mode." t)
(autoload 'python-mode "python-mode" "Python editing mode." t)
(autoload 'tcl-mode    "tcl-mode"    "TCL editing mode." t)
(autoload 'sh-script   "sh-mode"     "SH editing mode." t)

(setq auto-mode-alist
      (append '(("\\.test$" . pascal-mode)
                ("\\.tl$"   . c-mode)
                ("\\.py$"   . python-mode)
                ("\\.py$"   . ropemacs-mode)
                ("\\.php$"  . php-mode)
                ("\\.[jwedr]ar$" . archive-mode)
                ("\\.bash$"    . sh-mode)
                ("\\.sh$"      . sh-mode)
                ("\\.ksh$"     . sh-mode)
;;              ("\\.zsh$"     . sh-mode)
                ("\\.(bashrc|.*profile|login|cshrc)$" . sh-script)
                ) auto-mode-alist))

(setq interpreter-mode-alist
      (cons '("python" . python-mode) interpreter-mode-alist))

;; Scala
(require 'scala-mode-auto)
(defun my-scala-mode-hook ()
;  (yas/minor-mode-on)
)
(add-hook 'scala-mode-hook 'my-scala-mode-hook)

;; antlr was broken
(setq antlr-indent-style "")

;; --------------------------------------------------------------
;; Key mappings
(define-key esc-map "s" 'my-trim-spaces-ateol-and-save)
(define-key global-map [\M-s]   'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-x\C-s" 'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-cs" 'my-trim-spaces-ateol-and-save)
;(global-set-key   [(meta s)] 'save-buffer)

(global-unset-key "\C-l")
(global-set-key   "\C-l\C-l" 'recenter)
(global-set-key   "\C-q" 'other-window)

(global-set-key   [end]  'end-of-line)
(global-set-key   [(control end)] 'end-of-buffer)
(global-set-key   [home] 'beginning-of-line)
(global-set-key   [(control home)] 'beginning-of-buffer)
(global-set-key   [(control tab)] 'buffer-ring)

;; The following lines are always needed.  Choose your own keys.
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock) ; not needed when global-font-lock-mode is on
(global-set-key "\C-l\C-y" 'org-store-link)
(global-set-key "\C-l\C-u" 'org-agenda)
(global-set-key "\C-l\C-i" 'org-iswitchb)

(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

(global-set-key "\M-p" 'scroll-down)
(global-set-key "\M-n" 'scroll-up)
(global-set-key (kbd "<C-tab>") 'bury-buffer)
(global-set-key (kbd "<C-S-_>") 'undo)
(global-set-key "\C-l\C-o" 'duplicate-line)
(global-set-key (kbd "<C-c v>") 'evaluate-buffer)

(message "Milkshakes!!")
