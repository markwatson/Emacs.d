;;
;; Simplistic .emacs file for NTEmacs
;;
;; T.Noble   03/03/2007

; Identify myself
(message "Loading init file .emacs file")

; Fix delete key.  Not sure why it was broken on XEmacs for NT...
(setq delete-key-deletes-forward t)

(add-to-list 'load-path "~/.emacs.d")

;; Load pymacs
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs")
(autoload 'pymacs-exec "pymacs")
(autoload 'pymacs-load "pymacs")
(eval-after-load "pymacs"
  '(add-to-list 'pymacs-load-path "~/.emacs.d/python"))

;; python modules
(pymacs-load "manglers")
;(setq ropemacs-enable-shortcuts nil)
;(setq ropemacs-local-prefix "C-c C-p")
(pymacs-load "ropemacs" "rope-")

;; haskell
(load "~/.emacs.d/haskell/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; snippets
(require 'yasnippet-bundle)

;; Org Mode
(setq load-path (cons "~/.emacs.d/org/lisp" load-path))
(setq load-path (cons "~/.emacs.d/org/contrib/lisp" load-path))
(require 'org-install)

;;; With my new ftp proxy daemon, I can now edit files using efs as follows:
;;;    /user--targethost@gatewayhost#1555:
;(require 'efs)

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

(defun buffer-ring ()
  "Works around a ring of buffers.
   Steps to the next buffer in list, putting the current buffer
   at the end of the selection list."
  (interactive) (bury-buffer (current-buffer))
  (switch-to-buffer (other-buffer)))

(defun kill-current-buffer ()
  "Kills the current buffer."
  (interactive)
  (kill-buffer (current-buffer)) )

(defun open-my-dot-emacs ()  "Opens ~/.emacs for editing."
  (interactive) (find-file "~/.emacs"))

(defun load-my-dot-emacs ()  "Runs ~/.emacs for editing."
  (interactive) (load-init-file))

(defun mouse-set-point-and-yank (event)
       "Sets the point at the mouse location, then yanks from Clipboard"
       (interactive "@e")
       (mouse-set-point event)
       (yank-clipboard-selection))

(defun my-kill-current-line (&optional arg)
  "Deletes the entire current line and leaves cursor at start of line."
  (interactive "p")
  (if mark-active
      (kill-region (region-beginning) (region-end))
    (save-excursion
      (beginning-of-line)
      (kill-line arg))))

(defun my-kill-region-append (beg end)
  "Deletes the current region appending to last kill.
Useful if you want to do this in one keystroke."
  (interactive "r")
  (append-next-kill)
  (kill-region beg end))

(defun my-delete-char-or-region (&optional arg)
  "Deletes the current region (if any) or the current char."
  (interactive "p")
  (if mark-active
      (delete-region (region-beginning) (region-end))
    (delete-char arg)))

(defun my-delete-region-yank (&optional arg)
  "Deletes region if mark is active and yanks the last kill.
Always replaces the region with the yank, whether the region was
selected via keyboard or mouse.  Also works for normal
yank even with ARGS (thus it can be mapped to \C-y)"
  (interactive "p")
  ;-- old implementation - very problematic
  ;  (if mark-active
  ;      (delete-region (region-beginning) (region-end)))
  ;  (yank arg))
  ;--
  (if mark-active
      (let ((str (buffer-substring (point) (mark))))
        (delete-region (point) (mark))
        (if (string= str (current-kill 0 1))
            (let ((str2 (current-kill 1 1)))
              (kill-new str2 t)))))
  (if arg
      (yank arg)
    (yank)))

(defun my-kill-ring-save-append (beg end)
  "Copies the current region appending to last kill.
Useful if you want to do this in one keystroke."
  (interactive "r")
  (append-next-kill)
  (kill-ring-save beg end))

(defun my-copy-current-line (&optional arg)
  "Copies the current region or current line to kill ring.
With prefix ARG, copies ARG lines if the mark is not active."
  (interactive "p")
  (if mark-active
      (kill-ring-save (region-beginning) (region-end))
    (progn
      (beginning-of-line)
      (let ((beg (point)))
        (forward-line (or arg 1))
        (kill-ring-save beg (point))))))

(defun my-paste-current-line (&optional arg)
  "Pastes the current line from kill ring.  Useful right
after my-copy-current-line"
  (interactive "p")
  (save-excursion
    (beginning-of-line)
    (yank arg)))

;;
;; Current directory handling for shell mode
;;
(require 'shell)
(defvar my-last-prompt-string "x"
  "The last prompt string encountered in the shell buffer (buffer-local).")
(make-variable-buffer-local 'my-last-prompt-string)

(defun my-adjust-default-directory (out-str)
  (if (and (eq major-mode 'shell-mode)
           (and out-str (not (string= out-str ""))))
      (progn
        ;(message (concat "out-str is: '" out-str "'"))
        (if (string-match (concat "\\(" comint-prompt-regexp "\\)") out-str)
            (let ((pr-string (substring out-str (match-beginning 1) (match-end 1))))
              (if (not (string= pr-string my-last-prompt-string))
                  (progn
                    (setq my-last-prompt-string pr-string)
                    (my-shell-resync-dirs))))))))

(add-hook 'shell-mode-hook
          (function (lambda ()
                      ;(setq comint-process-echoes t)     ;; sometimes needed for cygwin 1.1.4 bash
                      (setq comint-input-ring-size 64)
                      ;(define-key comint-mode-map "\C-c\C-c" 'my-comint-interrupt-subjob)
                      (setq comint-prompt-regexp "^\\.\\.\\./[^#$%>\n]*[#$%>] *")
                      (add-hook 'comint-output-filter-functions
                                'comint-strip-ctrl-m)
                      (add-hook 'comint-output-filter-functions
                                'my-adjust-default-directory))))

;;
;;;; -- Shell re-sync support to fix cwd when needed
;;
(defvar my-shell-echo-broken nil
"Set to true if using cygnus 1.1.4 where shell command echo is enabled.")

;; A "better" version of shell-resync-dirs that handles shell echo properly
(defun my-shell-resync-dirs ()
  "Resync the current directory for the shell.
Supports command echo ala cygnus 1.1.4, whereas shell-resync-dirs did not."
  (interactive)
  (let ((env-pwd (my-shell-snarf-envar "PWD")))
    (message (concat "default-directory is: " env-pwd))
    (shell-cd env-pwd)))

;; Copied from shell.el on GNU Emacs 20.7.1 win32, modified to handle
;; cygnus 1.1.4 command echo problem
(defun my-shell-snarf-envar (var)
  "Return as a string the shell's value of environment variable VAR.
If the shell echos the command input before running the command,
set my-shell-echo-broken to ignore that line before looking for
the real environment variable contents."
  (let* ((cmd (format "printenv '%s'\n" var))
         (proc (get-buffer-process (current-buffer)))
         (pmark (process-mark proc)))
    (goto-char pmark)
    (insert cmd)
    (sit-for 0)				; force redisplay
    (comint-send-string proc cmd)
    (set-marker pmark (point))
    (let ((pt (point)))			; wait for 1 line
      ;; This extra newline prevents the user's pending input from spoofing us.
      (insert "\n") (backward-char 1)
      (if my-shell-echo-broken
          (progn
            ;; Eat the first line of input, it's the echo'd command
            (while (not (looking-at ".+\n"))
              (accept-process-output proc)
              (goto-char pt))
            (beginning-of-line)
            (forward-line)
            (setq pt (point))))
      ;; Get the line of input
      (while (not (looking-at ".+\n"))
        (accept-process-output proc)
        (goto-char pt)))
    (goto-char pmark) (delete-char 1)	; remove the extra newline
    (buffer-substring (match-beginning 0) (1- (match-end 0)))))

(defun my-trim-spaces-ateol-and-save ()
  "Trim trailing spaces at the end of every line in current buffer and save buffer."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (re-search-forward "[ \t]+$" nil t)
      (replace-match "" nil nil))
    (save-buffer)))

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

(require 'font-lock)
(global-font-lock-mode t)
(setq-default font-lock-global-modes '(not speedbar-mode text-mode))

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

;; ------ BASH shell
;; Set up for bash shell (comment this section to use cmd.exe).  Note
;; that I also DO NOT set SHELL=bash in my NT environment, since it
;; breaks compiles from certain other editors.
(setq binary-process-input t)
;(setq binary-process-output nil)
;(setq process-coding-system-alist '(("bash" . undecided-unix)))

;; Setup Emacs to run bash as its primary shell.
;(setq shell-file-name "bash.exe")
;(setq explicit-sh-args '("-login" "-i"))
;;(setq shell-file-name "zsh") ;; or sh if you rename your bash executable to sh.
;;(setq explicit-sh-args '("-l" "-i"))   ; for zsh
;(setq shell-command-switch "-c")
;(setq explicit-shell-file-name shell-file-name)
;(setenv "SHELL" shell-file-name)
;(if (boundp 'w32-quote-process-args)
;    (setq w32-quote-process-args ?\")) ;; Include only for MS Windows.

;; Setup for win32 cmdproxy.exe that ships with FSF emacs
;(require 'shell)
;;(setq shell-file-name "c:/mks/mksnt/sh.exe")
(setq shell-file-name "c:/emacs/bin/cmdproxy.exe")
;(setq w32-quote-process-args nil)
(setq w32-quote-process-args ?\")
(setq shell-command-switch "-c")
;(setq shell-command-switch "/c")
(setq explicit-shell-file-name shell-file-name)
(add-hook 'shell-mode-hook
          '(lambda ()
             (setq comint-prompt-regexp "^[^#$%>\n]*[#$%>] *")))

(if (load "text-mode" t)
    (progn
      (setq text-mode-map (make-sparse-keymap))
      ;; Couple of defaults that I kept (from textmodes/text-mode.el FSF 20.7.1)
      (define-key text-mode-map "\e\t" 'ispell-complete-word)
      (define-key text-mode-map "\t" 'indent-relative)
      (define-key esc-map "s" 'my-trim-spaces-ateol-and-save)
      (define-key text-mode-map [\M-s]   'my-trim-spaces-ateol-and-save)))

(require 'cc-mode)
(defconst my-c-style3
  '((c-tab-always-indent        . t)
    (c-basic-offset             . 3)
    (c-comment-only-line-offset . 3)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 3)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "My C Programming Style Indent 3")

(defconst my-c-style4
  '((c-tab-always-indent        . t)
    (c-basic-offset             . 4)
    (c-comment-only-line-offset . 4)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 4)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "My C Programming Style Indent 4")

(defconst my-php-style
  '((c-tab-always-indent        . t)
    (c-basic-offset             . 2)
    (c-comment-only-line-offset . 2)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 2)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "My PHP Programming Style")

;; Customizations for all of c-mode, c++-mode, and objc-mode
(defun my-c-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (c-add-style "PERSONAL" my-c-style4 t)
  ;; offset customizations not in my-c-style
  (c-set-offset 'member-init-intro '++)
  ;; other customizations
  (setq tab-width 8
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we don't like auto-newline and hungry-delete
  ;(c-toggle-auto-hungry-state 1)
  ;; keybindings for all supported languages.  We can put these in
  ;; c-mode-base-map because c-mode-map, c++-mode-map, objc-mode-map,
  ;; java-mode-map, and idl-mode-map inherit from it.
  (define-key c-mode-base-map "\C-m" 'newline-and-indent)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(defun my-php-mode-hook ()
  ;; add my personal style and set it for the current buffer
  (c-add-style "PHP_PERSONAL" my-php-style t)
  (font-lock-mode t))

(add-hook 'php-mode-hook 'my-php-mode-hook)

(require 'scala-mode-auto)
(defun my-scala-mode-hook ()
;  (yas/minor-mode-on)
)
(add-hook 'scala-mode-hook 'my-scala-mode-hook)


;; --------------------------------------------------------------
;; Key mappings

(global-set-key "\C-d" 'my-delete-char-or-region)
(global-set-key "\C-y" 'my-delete-region-yank)
(global-set-key "\M-w" 'my-copy-current-line)
(global-set-key "\C-w" 'my-kill-current-line)
(global-set-key "\M-\C-y" 'my-paste-current-line)

(define-key esc-map "s" 'my-trim-spaces-ateol-and-save)
(define-key global-map [\M-s]   'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-x\C-s" 'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-cs" 'my-trim-spaces-ateol-and-save)
;(global-set-key   [(meta s)] 'save-buffer)

(global-set-key   [(meta u)] 'advertised-undo)
(global-set-key   [(meta o)] 'call-last-kbd-macro)
(global-set-key   [(meta k)] 'kill-current-buffer)

(global-unset-key "\C-l")
(global-set-key   "\C-l\C-l" 'recenter)
(global-set-key   "\C-q" 'other-window)
;  (global-set-key "\C-l\C-a" 'beginning-of-buffer)
;  (global-set-key "\C-l\C-c" 'my-kill-ring-save-append)
;  (global-set-key "\C-l\C-d" 'delete-region)
;  (global-set-key "\C-l\C-e" 'end-of-buffer)
;  (global-set-key "\C-l\C-f" 'find-this-file)
;  (global-set-key "\C-l\C-k" 'my-kill-current-line)
;  (global-set-key "\C-l\C-m" 'compile)
;  (global-set-key "\C-l\C-n" 'new-shell)
;  (global-set-key "\C-l\C-r" 'isearch-backward-regexp)
;  (global-set-key "\C-l\C-s" 'isearch-forward-regexp)
;  (global-set-key "\C-l\C-t" 'my-toggle-indent-tabs-mode)
;  (global-set-key "\C-l\C-u" 'advertised-undo)
;  (global-set-key "\C-l\C-w" 'my-kill-region-append)
;  (global-set-key "\C-l\C-x" 'my-kill-region-append)
;  (global-set-key "\C-l\C-y" 'my-paste-current-line)
;  (global-set-key "\C-l\M-w" 'my-kill-ring-save-append)
;  (global-set-key "\C-le1"   'first-error)
;  (global-set-key "\C-len"   'next-error)
;  (global-set-key "\C-lep"   'previous-error)
;  (global-set-key "\C-lsc"   'clearshell)
;  (global-set-key "\C-lss"   'my-shell-resync-dirs)
;  (global-set-key "\C-lh"    'hippie-expand)
;  (global-set-key "\C-lj"    'goto-line)
;  (global-set-key "\C-lr"    'query-replace-regexp)
;  (global-set-key "\C-lm"    'bookmark-set)
;  (global-set-key "\C-l'"    'bookmark-jump)
  (global-set-key "\C-l\C-e" 'manglers-do-expand-regex)

  (global-set-key   "\C-lsc" 'clearshell)

(global-set-key   [end]  'end-of-line)
(global-set-key   [(control end)] 'end-of-buffer)
(global-set-key   [home] 'beginning-of-line)
(global-set-key   [(control home)] 'beginning-of-buffer)
(global-set-key   [(control tab)] 'buffer-ring)

;(global-set-key   [f2]    'save-buffer)
;(global-set-key   [f3]    'kill-current-buffer)
;(global-set-key   [f4]    'query-replace-regexp)
;(global-set-key   [f5]    'goto-line)
;(global-set-key   [f6]    'other-window)
;(global-set-key   [f7]    'delete-other-windows)
;(global-set-key   [f8]    'buffer-ring)
;(global-set-key   [f9]    'advertised-undo)
;(global-set-key   [f10]   'call-last-kbd-macro)

(global-set-key   [(control f4)] 'kill-current-buffer)
(global-set-key   [(control f10)] 'open-my-dot-emacs)
(global-set-key   [(meta f10)] 'load-my-dot-emacs)
(global-set-key   [(control button1)] 'copy-primary-selection)  ; to Clipboard + kill
(global-set-key   [(control button3)] 'mouse-drag-or-yank)      ; from last emacs kill
(global-set-key   [(shift button3)] 'mouse-set-point-and-yank)  ; from Clipboard at mouse
(global-set-key   [(meta button3)] 'yank-clipboard-selection)   ; from Clipboard at point
; note: default for C-button1 in XEmacs for NT is 'mouse-track-insert

;; The following lines are always needed.  Choose your own keys.
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock) ; not needed when global-font-lock-mode is on
(global-set-key "\C-l\C-y" 'org-store-link)
(global-set-key "\C-l\C-u" 'org-agenda)
(global-set-key "\C-l\C-i" 'org-iswitchb)

(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

;; End key mappings
;; --------------------------------------------------------------


;; Mark's Modifications


;; include path
(add-to-list 'load-path "~/.emacs.d")

;; antlr was broken
(setq antlr-indent-style "")

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
(set-default-font "ProgCleanCO")

;; you know you looking at a winner...
(when (fboundp 'winner-mode)
  (winner-mode 1))

; php mode
;(add-to-list 'load-path "~/.emacs.d/php-mode")
;(require 'php-mode)

;; special save
(defun my-trim-spaces-ateol-and-save ()
  "Trim trailing spaces at the end of every line in current buffer and save buffer."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (re-search-forward "[ \t]+$" nil t)
      (replace-match "" nil nil)
    )
    (save-buffer)
  )
)

(define-key esc-map "s" 'my-trim-spaces-ateol-and-save)
(define-key global-map [\M-s]   'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-x\C-s" 'my-trim-spaces-ateol-and-save)
(define-key global-map "\C-cs" 'my-trim-spaces-ateol-and-save)

;; dup line
(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)

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

;; IDO
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

;; key bindings
(global-set-key "\M-p" 'scroll-down)
(global-set-key "\M-n" 'scroll-up)
(global-set-key (kbd "<C-tab>") 'bury-buffer)
(global-set-key (kbd "<C-S-_>") 'undo)
(global-set-key "\C-l\C-o" 'duplicate-line)
(global-set-key (kbd "<C-c v>") 'evaluate-buffer)

(message "All done!")
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
