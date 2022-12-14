;; UI CONFIG
(scroll-bar-mode -1)
(tooltip-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10)
(set-face-attribute 'default nil :font "Code New Roman" :height 120) ;; setting the font
(set-face-attribute 'fixed-pitch nil :font "Code New Roman" :height 120) 
(set-face-attribute 'variable-pitch nil :font "Roboto" :height 120 :weight 'regular) 

;; line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; disable line numbering for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                vterm-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
(add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Setting up packages
(require 'package)
(setq package-archives '(("melpa". "https://melpa.org/packages/")
                         ("org"  . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1)) ;; setting up ivy

(use-package counsel
  :bind (("M-x"     . counsel-M-x)
         ("C-x b"   . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil))

  ;; ivy rich
  (use-package ivy-rich
    :after ivy
    :config
    (ivy-rich-mode 1))

;; all-the-icons
(use-package all-the-icons)

;; Setting up doom-modeline
(use-package doom-modeline
  :ensure t
  :config
  (doom-modeline-mode 1))

;; doom themes
(use-package doom-themes
  :init
  (load-theme 'doom-city-lights t)) ;; loading the theme

;; Rainbow parantheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which-key integration
(use-package which-key
  :diminish which-key-mode
  :defer 0
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode))

;; helpful
(use-package helpful
    :commands (helpful-callable helpful-variable helpful-command helpful-key)
    :custom
    (counsel-describe-function-function #'helpful-callable)
    (counsel-describe-variable-function #'helpful-variable)
    :bind
    ([remap describe-function] . counsel-describe-function)
    ([remap describe-command] . helpful-command)
    ([remap describe-variable] . counsel-describe-variable)
    ([remap describe-key] . helpful=key))

;; evil-mode

 (use-package evil
   :init
   (setq evil-want-integration t)
   (setq evil-want-keybinding nil)
   (setq evil-want-C-i-jump nil)
   :config
   (evil-mode 1)
   (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
   (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

   ;; use visual lines
   (evil-global-set-key 'motion "j" 'evil-next-visual-line)
   (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

   (evil-set-initial-state 'messages-buffer-mode 'normal)
   (evil-set-initial-state 'dashboard-mode 'normal))

 ;; evil collection
 (use-package evil-collection
   :after evil
   :config
   (evil-collection-init))

;; hydra

(use-package hydra
  :defer t
  :config
  (defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t)))

;; general
(use-package general
  :after evil
  :config 
  (general-evil-setup 1)
  (general-create-definer ez/leader-keys
    :keymaps '(normal visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

;; projectile

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :defer t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/dev/projects")
    (setq projectile-project-search-path '("~/dev/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

; counsel-projectile
(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

;; magit

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; forge

(use-package forge
  :config
  (setq auth-sources '("~/.authinfo"))
  :custom
  (forge-add-default-bindings nil)
  :after magit)

;; org-mode


 (use-package org
   :hook (org-mode . ez/org-mode-setup)
   :config

 (defun ez/org-mode-setup ()
   (org-indent-mode)
   (variable-pitch-mode 1)
   (visual-line-mode 1))

 (defun ez/org-setup-faces ()
   ;; Set faces for heading levels
   (dolist (face '((org-level-1 . 1.2)
                 (org-level-2 . 1.1)
                 (org-level-3 . 1.05)
                 (org-level-4 . 1.0)
                 (org-level-5 . 1.1)
                 (org-level-6 . 1.1)
                 (org-level-7 . 1.1)
                 (org-level-8 . 1.1)))
     (set-face-attribute (car face) nil :font "Roboto" :weight 'extra-bold :height (cdr face)))
   ;; Ensure that anything that should be fixed-pitch in Org files appears that way
   (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
   (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
   (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
   (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
   (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
   (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
   (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
   (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
   (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
   (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
   (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

   (setq org-ellipsis " ???"
         org-hide-emphasis-markers t)
   (ez/org-setup-faces)
   (setq org-agenda-files '("~/.emacs.d/tasks.org"))
   (setq org-agenda-start-with-log-mode t)
   (setq org-log-done 'time)
   (setq org-log-into-drawer t)
   :custom
   (org-tag-alist
    '(("@home" . ?H)
      ("@school" . ?S)
      ("programming" . ?p)
      ("chess" . ?c)
      ("speedcubing" . ?s)
      ("reading" . ?r)
      (org-refile-targets
       '(("tasks-archive.org" :maxlevel . 1)
         ("tasks.org" :maxlevel . 1)))
   )))


 (use-package org-bullets
   :hook (org-mode . org-bullets-mode)
   :custom
   (org-bullets-bullet-list '("???" "???" "???" "???" "???" "???" "???")))


 (with-eval-after-load 'org
   (org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (C . t)
    (js . t)
    (css . t)
    (shell . t)
    (sql . t)))

 (require 'org-tempo)
 (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
 (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
 (add-to-list 'org-structure-template-alist '("cl" . "src C"))
 (add-to-list 'org-structure-template-alist '("cpp" . "src C++"))
 (add-to-list 'org-structure-template-alist '("js" . "src js"))
 (add-to-list 'org-structure-template-alist '("css" . "src css"))
 (add-to-list 'org-structure-template-alist '("sql" . "src sql"))

 (require 'org-habit)
 (add-to-list 'org-modules 'org-habit)
 (setq org-habit-graph-column 60)
 ;; Save org buffers after refiling
 (advice-add 'org-refile :after 'org-save-all-org-buffers))

 ; visual-fill-column


 (use-package visual-fill-column
   :config
   (defun ez/org-mode-visual-fill ()
   (setq visual-fill-column-width 100
         visual-fill-column-center-text t)
   (visual-fill-column-mode 1))
   (defun ez/org-babel-tangle-config ()
     (when (string-equal (buffer-file-name)
                         (expand-file-name "~/.config/emacs/emacs.org"))
       (let ((org-confirm-babel-evaluate nil))
         (org-babel-tangle))))
   (add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'ez/org-babel-tangle-config)))
   :hook (org-mode . ez/org-mode-visual-fill))

   ;; Automatically tangle babel.org when we save it

(use-package yasnippet
  :hook (lsp-mode . yas-minor-mode)
  :config
  (yas-reload-all))
(use-package yasnippet-snippets
  :after yasnippet)
(use-package ivy-yasnippet
  :after yasnippet)

(defun ez/lsp-mode-setup()
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
:commands (lsp lsp-deferred)
:after yasnippet
:hook (lsp-mode . ez/lsp-mode-setup)
:custom
(lsp-keymap-prefix "C-c l")
:config
(lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))

(use-package lsp-treemacs
  :after lsp
  :config
  (treemacs-load-theme "doom-city-lights"))

(use-package lsp-ivy
  :after lsp-mode)
(add-hook 'prog-mode-hook 'electric-pair-mode)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(add-hook 'c-mode-hook #'lsp-deferred)
(add-hook 'c++-mode-hook #'lsp-deferred)

(use-package typescript-mode
:mode "\\.ts\\'"
:hook (typescript-mode . lsp-deferred)
:custom
(typescript-indent-level 2))

(add-hook 'js-mode-hook #'lsp-deferred)
(setq js-indent-level 2)

(use-package emmet-mode
  :hook (html-mode-hook . emmet-mode))
(add-hook 'html-mode-hook #'lsp-deferred)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package page-break-lines)
(use-package dashboard
  :after page-break-lines
  :config
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-items '((recents . 5)
                     (projects . 5)
                     (agenda . 5)))
  (dashboard-startup-banner 'logo))

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :after vterm
  :config

  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                  (let ((buffer (get-buffer buffer-or-name)))
                   (with-current-buffer buffer
                     (or (equal major-mode 'vterm-mode)
                         (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
              ;;(display-buffer-reuse-window display-buffer-at-bottom)
              (display-buffer-reuse-window display-buffer-in-direction)
              ;;display-buffer-in-direction/direction/dedicated is added in emacs27
              (direction . bottom)
              (dedicated . t) ;dedicated is supported in emacs27
              (reusable-frames . visible)
              (window-height . 0.3))))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :custom
  (dired-open-extensions '(("png" . "sxiv")
                           ("jpg" . "sxiv")
                           ("mkv" . "mpv" ))))
(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package auto-package-update
  :defer 2
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe))

(use-package tree-sitter
  :hook (lsp-mode . tree-sitter-mode)
  :config
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs
  :after tree-sitter)

(use-package flycheck
  :ensure t
  :hook (lsp-mode . flycheck-mode)
  :custom
  (flycheck-javascript-standard-executable "~/.local/share/npm/bin/standard"))

(use-package format-all
  :hook (lsp-mode . format-all-mode)
  )

(setq user-emacs-directory "~/.cache/emacs")
 (use-package no-littering)

(setq auto-save-file-name-transforms
       `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(use-package gcmh
  :config (gcmh-mode 1))

;; KEYBINDINGS
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(general-define-key
 "C-M-j" 'counsel-switch-buffer)

(ez/leader-keys
 "t" '(:ignore t :which-key "toggles")
 "v" '(vterm-toggle :which-key "toggle terminal")
 "ts" '(hydra-text-scale/body :which-key "scale text"))
