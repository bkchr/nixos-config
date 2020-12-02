;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(after! rustic
  (map! :map rustic-mode-map :localleader ("o" #'rustic-open-dependency-file))
  (setq rustic-lsp-server 'rust-analyzer))

(after! lsp-rust
  ;; disable the eldoc stuff
  (setq lsp-eldoc-hook nil)
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-rust-analyzer-use-client-watching nil)
  (setq lsp-auto-guess-root t)
  (setq lsp-enable-file-watchers nil)
  ;; Use the wrapped rust analyzer to always load the correct direnv environment
  (setq lsp-rust-analyzer-server-command "rust-analyzer-wrapped")
  (setq lsp-rust-analyzer-cargo-override-command [ "rust-analyzer-cargo-check" ])
  ;; (setq lsp-rust-analyzer-proc-macro-enable t)
  ;; (setq lsp-rust-analyzer-cargo-load-out-dirs-from-check t)
)

(setq display-line-numbers-type 'relative)

(setq show-trailing-whitespace t)

;; Enable global whitespace mode
(global-whitespace-mode 1)

(add-hook 'diff-mode-hook 'whitespace-mode)

(setq whitespace-style '(face tabs tab-mark spaces space-mark trailing lines-tail))

;; Make flycheck use direnv to get the correct env for finding an executable
;; We also need to enable `envrc-mode` manually for this buffer to make sure we set the
;; env variables for this buffer (the mode is probably enabled later).
(setq flycheck-executable-find
     (lambda (cmd) (envrc-mode 1)(envrc--update-env default-directory)(executable-find cmd)))

(defun save-all ()
  (interactive)
  (save-some-buffers t))

;; Save all buffers when emacs looses the focus
(add-hook 'focus-out-hook 'save-all)
;; Autosave to the file directly
(auto-save-visited-mode 1)

;;(after! prog-mode
;;  (set-company-backend! 'prog-mode 'company-abbrev-code))

;; Save all buffers before searching a project
(advice-add #'+default/search-project :before (lambda (&rest _) (evil-write-all nil)))

(after! company
  ;; Trigger completion immediately.
  (setq company-idle-delay 0))

(after! org
  (defun org-get-agenda-files-recursively (dir)
    "Get org agenda files from root DIR."
    (directory-files-recursively dir "\.org$"))
  
  (defun org-set-agenda-files-recursively (dir)
    "Set org-agenda files from root DIR."
    (setq org-agenda-files 
      (org-get-agenda-files-recursively dir)))
  
  (defun org-add-agenda-files-recursively (dir)
    "Add org-agenda files from root DIR."
    (nconc org-agenda-files 
      (org-get-agenda-files-recursively dir)))
  (org-set-agenda-files-recursively "~/org") 
  (setq org-roam-directory "~/org/roam/")
  (setq org-directory "~/org/")

  (setq org-capture-templates
      `(("i" "inbox" entry (file ,"~/org/inbox.org")
         "* TODO %?")
        ("l" "link" entry (file ,"~/org/inbox.org")
         "* TODO %(org-cliplink-capture)" :immediate-finish t)
        ("c" "org-protocol-capture" entry (file ,"~/org/inbox.org")
         "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)))
  (setq org-todo-keywords
  '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "DONE(d)"))))
