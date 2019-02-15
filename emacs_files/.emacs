;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File name: ` ~/.emacs '
;;; ---------------------
;;;
;;; If you need your own personal ~/.emacs
;;; please make a copy of this file
;;; an placein your changes and/or extension.
;;;
;;; Copyright (c) 1997-2002 SuSE Gmbh Nuernberg, Germany.
;;;
;;; Author: Werner Fink, <feedback@suse.de> 1997,98,99,2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Test of Emacs derivates
;;; -----------------------

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(if (string-match "XEmacs\\|Lucid" emacs-version)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; XEmacs
  ;;; ------
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (progn
     (if (file-readable-p "~/.xemacs/init.el")
        (load "~/.xemacs/init.el" nil t))
  )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; GNU-Emacs
  ;;; ---------
  ;;; load ~/.gnu-emacs or, if not exists /etc/skel/.gnu-emacs
  ;;; For a description and the settings see /etc/skel/.gnu-emacs
  ;;;   ... for your private ~/.gnu-emacs your are on your one.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (if (file-readable-p "~/.gnu-emacs")
      (load "~/.gnu-emacs" nil t)
    (if (file-readable-p "/etc/skel/.gnu-emacs")
	(load "/etc/skel/.gnu-emacs" nil t))) )


  ;; Custom Settings
  ;; ===============
  ;; To avoid any trouble with the customization system of GNU emacs
;; we set the default file ~/.gnu-emacs-custom
;; Melpa
(require 'package)
;; (add-to-list 'package-archives
;;              '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)


(setq custom-file "~/.gnu-emacs-custom")
(load "~/.gnu-emacs-custom" t t)
(set-face-attribute 'default nil :height 130)
(global-linum-mode t) 
;;----------------------------------------------------------------
;; Use Package
;;------------------------------enfo----------------------------------

;; ;; Bootstrap `use-package'
;; (unless (package-installed-p 'use-package)
;; 	(package-refresh-contents)
;; 	(package-install 'use-package))
;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  ;;(add-to-list 'load-path "<path where use-package is installed>")
  (require 'use-package))
;;---------------------------------------------------------------------
;;  Tweaks
;;---------------------------------------------------------------------
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)

(use-package try )

(use-package which-key
	:config
	(which-key-mode))
;;-----------------------------------------------------------------------
;;  IVY
;;-----------------------------------------------------------------------
(use-package ivy
    :config
    (progn
      (ivy-mode 1)
      (setq ivy-use-virtual-buffers t)
      (setq ivy-count-format "(%d/%d) ")
      (setq enable-recursive-minibuffers t)
      (setq ivy-display-style 'fancy))
    :bind
    (( "C-s" . swiper)
     ( "M-x" . counsel-M-x)
     ( "C-c C-r" . ivy-resume)
     ( "<f6>" . ivy-resume)
     ( "C-x C-f" . counsel-find-file)
     ( "<f1>" .  nil)
     ( "<f1> f" . counsel-describe-function)
     ( "<f1> v" . counsel-describe-variable)
     ( "<f1> l" . counsel-find-library)
     ( "<f2> i" . counsel-info-lookup-symbol)
     ( "<f2> u" . counsel-unicode-char)
     ( "C-c g" . counsel-git)
     ( "C-c j" . counsel-git-grep)
     ( "C-c k" . counsel-ag)
     ( "C-x l" . counsel-locate)
     ( "C-S-o" . counsel-rhythmbox)) )


;;------------------------------------------------------------------
;; Org and Org ref
;;-----------------------------------------------------------------
(custom-set-variables
 '(org-directory "~/Documents/docs/Management/")
 '(org-default-notes-file (concat org-directory "/notes.org"))
 '(org-export-html-postamble nil)
 '(org-hide-leading-stars t)
 '(org-startup-folded (quote overview))
 '(org-startup-indented t))

(use-package org-ref
  :config
  (progn
    (setq org-ref-completion-library 'org-ref-ivy-cite)
    (setq reftex-default-bibliography '("~/Documents/docs/Management/bibliography/org-refs.bib"))
    (setq org-ref-bibliography-notes "~/Documents/docs/Management/bibliography/notes.org"
	  org-ref-default-bibliography '("~/Documents/docs/Management/bibliography/org-refs.bib")
	  org-ref-pdf-directory "~/Documents/docs/Management/bibliography/bibtex-pdfs/")
    (setq bibtex-completion-bibliography "~/Documents/docs/Management/bibliography/references.bib"
	  bibtex-completion-library-path "~/Documents/docs/Management/bibliography/bibtex-pdfs"
	  bibtex-completion-notes-path "~/Documents/docs/Management/bibliography/helm-bibtex-notes")
    (setq bibtex-completion-pdf-open-function
	  (lambda (fpath)
	    (start-process "open" "*open*" "open" fpath)))))


(use-package org-bullets
  :hook
  (org-mode .  (lambda () (org-bullets-mode 1))))



;;----------------------------------------------------------------
;; Org include image from pdf
;;----------------------------------------------------------------

(defun org-include-img-from-pdf (&rest _)
  "Convert pdf files to image files in org-mode bracket links.

    # ()convertfrompdf:t # This is a special comment; tells that the upcoming
                         # link points to the to-be-converted-to file.
    # If you have a foo.pdf that you need to convert to foo.png, use the
    # foo.png file name in the link.
    [[./foo.png]]
"
  (interactive)
  (if (executable-find "convert")
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward "^[ \t]*#\\s-+()convertfrompdf\\s-*:\\s-*t"
                                  nil :noerror)
          ;; Keep on going to the next line till it finds a line with bracketed
          ;; file link.
          (while (progn
                   (forward-line 1)
                   (not (looking-at org-bracket-link-regexp))))
          ;; Get the sub-group 1 match, the link, from `org-bracket-link-regexp'
          (let ((link (match-string-no-properties 1)))
            (when (stringp link)
              (let* ((imgfile (expand-file-name link))
                     (pdffile (expand-file-name
                               (concat (file-name-sans-extension imgfile)
                                       "." "pdf")))
                     (cmd (concat "convert -density 96 -quality 85 "
                                  pdffile " " imgfile)))
                (when (and (file-readable-p pdffile)
                           (file-newer-than-file-p pdffile imgfile))
                  ;; This block is executed only if pdffile is newer than
                  ;; imgfile or if imgfile does not exist.
                  (shell-command cmd)
                  (message "%s" cmd)))))))
    (user-error "`convert' executable (part of Imagemagick) is not found")))

(defun my/org-include-img-from-pdf-before-save ()
  "Execute `org-include-img-from-pdf' just before saving the file."
    (add-hook 'before-save-hook #'org-include-img-from-pdf nil :local))
(add-hook 'org-mode-hook #'my/org-include-img-from-pdf-before-save)



;-----------------------------------------------------------
;; alternative
;; (setq bibtex-completion-pdf-open-function 'org-open-file)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;     PYTHON 3    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jedi

(use-package jedi
  :hook
  (python-mode . jedi:setup)
  :init
  (setq jedi:complete-on-dot t)                 ; optional
  )


;; Elpy

(use-package elpy
  :config
  (elpy-enable)
  :init
  (progn
    (setq elpy-rpc-python-command "python3.6")
    (setq elpy-rpc-backend "jedi")                                                                    
    (setq python-shell-interpreter "python3.6";"jupyter"
	  python-shell-interpreter-args "";"console --simple-prompt"
	  python-shell-prompt-detect-failure-warning nil) 
    ) )
(add-to-list 'python-shell-completion-native-disabled-interpreters
		 "python3.6")
;; use flycheck not flymake with elpy;
; (when (require 'flycheck nil t)
;;   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;;   (add-hook 'elpy-mode-hook 'flycheck-mode))

;; enable autopep8 formatting on save
;; (use-package py-autopep8
;;   :ensure t
;;   :config (progn
;;            (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
;;            ((setq py-autopep8-options '("--ignore=E501,W293,W391,W690"))))
;; (require 'py-autopep8)
;; (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Magit
(use-package magit
  :bind
  ( "C-x g" . magit-status) )


;;-----------------------------------------------------------------
;; Yasnippet
;;-----------------------------------------------------------------
(use-package yasnippet
      :config
      (yas-global-mode 1))
(use-package auto-yasnippet)

;;----------------------------------------------------------------
;; Undo Tree
;;----------------------------------------------------------------
(use-package undo-tree
      :config
      (global-undo-tree-mode))

;;----------------------------------------------------------------
;; Line highlight and Beacon
;;----------------------------------------------------------------
(global-hl-line-mode t)
  
      ; flashes the cursor's line when you scroll
(use-package beacon      
  :config
  (beacon-mode 1)
  )

;;----------------------------------------------------------------
;; Expand Region and kill
;;----------------------------------------------------------------
(use-package expand-region
      :bind 
      ( "C-=" . er/expand-region))

(setq save-interprogram-paste-before-kill t)

(use-package easy-kill
  :bind
  (([remap kill-ring-save] . easy-kill)
  ([remap mark-sexp] . easy-mark)) )

;;----------------------------------------------------------------
;; Iedit and narrowing
;;----------------------------------------------------------------
(use-package iedit
  )
;;   :init
;;   ; if you're windened, narrow to the region, if you're narrowed, widen
;;   ; bound to C-x n
;;   (defun narrow-or-widen-dwim (p)
;;   "If the buffer is narrowed, it widens. Otherwise, it narrows intelligently.
;;   Intelligently means: region, org-src-block, org-subtree, or defun,
;;   whichever applies first.
;;   Narrowing to org-src-block actually calls `org-edit-src-code'.
  
;;   With prefix P, don't widen, just narrow even if buffer is already
;;   narrowed."
;;   (interactive "P")
;;   (declare (interactive-only))
;;   (cond ((and (buffer-narrowed-p) (not p)) (widen))
;;   ((region-active-p)
;;   (narrow-to-region (region-beginning) (region-end)))
;;   ((derived-mode-p 'org-mode)
;;   ;; `org-edit-src-code' is not a real narrowing command.
;;   ;; Remove this first conditional if you don't want it.
;;   (cond ((ignore-errors (org-edit-src-code))
;;   (delete-other-windows))
;;   ((org-at-block-p)
;;   (org-narrow-to-block))
;;   (t (org-narrow-to-subtree))))
;;   (t (narrow-to-defun))))

;; ;;-------------------------
;;---------------------------------------
;; Magit
;;----------------------------------------------------------------
;; (use-package magit
    
;;     :config
;;     (progn
;;     (bind-key "C-x g" 'magit-status)
;;     ))

;;----------------------------------------------------------------
;; ibuffer
;;----------------------------------------------------------------
(use-package ibuffer
   :bind ( "C-x C-b" . ibuffer) )
  ;; :init
  ;; ((setq ibuffer-show-empty-filter-groups nil)
  ;; (setq ibuffer-saved-filter-groups
  ;; 	(quote (("default"
  ;; 		 ("dired" (mode . dired-mode))
  ;; 		 ("org" (name . "^.*org$"))
  ;; 	       ("IRC" (or (mode . circe-channel-mode) (mode . circe-server-mode)))
  ;; 		 ("web" (or (mode . web-mode) (mode . js2-mode)))
  ;; 		 ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
  ;; 		 ("mu4e" (or

  ;;                (mode . mu4e-compose-mode)
  ;;                (name . "\*mu4e\*")
  ;;                ))
  ;; 		 ("programming" (or
  ;; 				 (mode . python-mode)
  ;; 				 (mode . c++-mode)))
  ;; 		 ("emacs" (or
  ;; 			   (name . "^\\*scratch\\*$")
  ;; 			   (name . "^\\*Messages\\*$")))
  ;; 		 )))) )
  ;; :hook (ibuffer-mode
  ;; 	    (lambda ()
  ;; 	      (ibuffer-auto-mode 1)
  ;; 	      (ibuffer-switch-to-saved-filter-groups "default")))
  

  ;; don't show these
					  ;(add-to-list 'ibuffer-never-show-predicates "zowie")
  ;; Don't show filter groups if there are no buffers in that group

;;----------------------------------------------------------------
;; Set browser
;;----------------------------------------------------------------
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium-browser")


;;-----------------------------------------------------------------
;;  THEMES
;;-----------------------------------------------------------------
(use-package color-theme-modern)
    
(use-package zenburn-theme
  :config (load-theme 'zenburn t))



        ;; ;(use-package spacemacs-theme
        ;; ;  
        ;; ;  ;:init
        ;; ;  ;(load-theme 'spacemacs-dark t)
        ;; ;  )
        ;; (use-package base16-theme
        
        ;; )
        ;; (use-package moe-theme
        ;; )


        ;; (use-package alect-themes
        ;; )

        ;; (use-package poet-theme
        
        ;; )
        ;; (use-package zerodark-theme
        ;; )

(use-package spaceline )

(use-package all-the-icons
  :config
  (progn
    (all-the-icons-octicon "file-binary")   ;; GitHub Octicon for Binary File
    (all-the-icons-faicon  "cogs")          ;; FontAwesome icon for cogs
    (all-the-icons-wicon   "tornado")))     ;; Weather Icon for tornado
 

(use-package spaceline-all-the-icons)

(use-package all-the-icons-ivy
  :config
  (all-the-icons-ivy-setup))

;;(provide '.emacs)
;;;
