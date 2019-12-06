(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; TABS
(setq backward-delete-char-untabify-method 'hungry
      indent-tabs-mode t
      c-basic-offset 4
      tab-width 4)
(setq-default indent-tabs-mode t
	      c-basic-offset 4
	      tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)

;; TEXT-MODE TABS
;;(define-key text-mode-map (kbd "TAB") 'self-insert-command)

;; SWITCH STATEMENT INDENT
;; (c-set-offset 'case-label '+)

;; ARG LIST INDENT
;;(c-set-offset 'arglist-intro '+)
;;(c-set-offset 'arglist-close 0)
;;(c-set-offset 'arglist-cont 0)
;;(c-set-offset 'arglist-cont-nonempty '+)

;; BACKUP FILES
(setq backup-directory-alist '(("." . "/home/pixlark/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5    ; and how many of the old
)

;; PROLOG MODE
(add-to-list 'auto-mode-alist '("\\.pro\\'" . prolog-mode))

;; MANUALLY LOADED PACKAGES
;;(add-to-list 'load-path "/home/pixlark/.emacs.d/lisp/")
;;(load "jai-mode")

;; AUTO INSERT

;; HTML EDITING
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-hook 'web-mode-hook
		  (lambda ()
			(setq web-mode-markup-indent-offset 2)))

;; COMMENT HOTKEY
(global-set-key (kbd "C-c p") (lambda ()
							   (interactive)
							   (insert (concat "/* -Paul T. " (current-time-string) " */" ))))

;; PRETTIFY
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

;; ORG MODE
(add-hook 'org-mode-hook
		  (lambda ()
			(org-indent-mode 1)))

;; PYTHON MODE
; what the fuck emacs
(add-hook 'python-mode-hook
		  (lambda ()
			(set-variable 'python-indent-offset 4)
			(setq tab-width 4
				  backward-delete-char-untabify-method 'hungry
				  indent-tabs-mode t)))
;; MACRO INDENT
(c-set-offset 'cpp-macro 0)

;; DOC-VIEW
(set-variable 'doc-view-continuous 'T)

;;(load "/home/pixlark/.emacs.d/llvm-mode.el")
;;(add-hook 'llvm-mode-hook
;;		  (lambda ()
;;			(local-set-key (kbd "<tab>") 'tab-to-tab-stop)))

;; Font

;;(ignore-errors (set-default-font "Ubuntu Mono 14"))
(ignore-errors (set-default-font "SF Mono 14"))

;; SQL indentation

(add-hook 'sql-mode-hook
		  (lambda ()
			(sqlind-minor-mode)))

;; JS2

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

;; badge-mode

;;(load "/home/pixlark/prog/C++/badge/emacs/badge-mode.el")

;; fmt keybinds
(add-hook 'rust-mode-hook
		  (lambda ()
			(local-set-key (kbd "C-c f")
						   (lambda ()
							 (interactive)
							 (rust-format-buffer)))))
(add-hook 'go-mode-hook
		  (lambda ()
			(local-set-key (kbd "C-c f")
						   (lambda ()
							 (interactive)
							 (gofmt)))))

;; go-rename
;; (add-hook 'go-mode-hook
;; 		  (lambda ()
;; 			(local-set-key (kbd "C-c g")
;; 						   (interactive)
;; 						   (go-rename))))
;; doesn't work

;; inhibit startup screen
(set-variable 'inhibit-startup-screen 't)

;; SLIME
(setq inferior-lisp-program "sbcl")
(add-hook 'lisp-mode-hook
		  (lambda ()
			(interactive)
			(show-paren-mode)))
(add-hook 'comint-mode-hook
		  (lambda ()
			(local-set-key (kbd "C-x x")
						   (lambda ()
							 (interactive)
							 (slime-quit-lisp)
							 (delete-window)))))

;; https://emacs.stackexchange.com/questions/39034/prefer-vertical-splits-over-horizontal-ones
(defun split-window-sensibly-prefer-horizontal (&optional window)
"Based on split-window-sensibly, but designed to prefer a horizontal split,
i.e. windows tiled side-by-side."
  (let ((window (or window (selected-window))))
    (or (and (window-splittable-p window t)
         ;; Split window horizontally
         (with-selected-window window
           (split-window-right)))
    (and (window-splittable-p window)
         ;; Split window vertically
         (with-selected-window window
           (split-window-below)))
    (and
         ;; If WINDOW is the only usable window on its frame (it is
         ;; the only one or, not being the only one, all the other
         ;; ones are dedicated) and is not the minibuffer window, try
         ;; to split it horizontally disregarding the value of
         ;; `split-height-threshold'.
         (let ((frame (window-frame window)))
           (or
            (eq window (frame-root-window frame))
            (catch 'done
              (walk-window-tree (lambda (w)
                                  (unless (or (eq w window)
                                              (window-dedicated-p w))
                                    (throw 'done nil)))
                                frame)
              t)))
     (not (window-minibuffer-p window))
     (let ((split-width-threshold 0))
       (when (window-splittable-p window t)
         (with-selected-window window
           (split-window-right))))))))

(defun split-window-really-sensibly (&optional window)
  (let ((window (or window (selected-window))))
    (if (> (window-total-width window) (* 2 (window-total-height window)))
        (with-selected-window window (split-window-sensibly-prefer-horizontal window))
      (with-selected-window window (split-window-sensibly window)))))

(setq
   split-height-threshold 4
   split-width-threshold 40 
   split-window-preferred-function 'split-window-really-sensibly)

;; DEUTSCH

(add-hook 'text-mode-hook
		  (lambda ()
			(local-set-key
			 (kbd "C-c a")
			 (lambda () (interactive) (insert-char ?ä)))
			(local-set-key
			 (kbd "C-c o")
			 (lambda () (interactive) (insert-char ?ö)))
			(local-set-key
			 (kbd "C-c u")
			 (lambda () (interactive) (insert-char ?ü)))))
