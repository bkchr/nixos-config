;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(after! rustic
  (map! :map rustic-mode-map :localleader ("o" #'rustic-open-dependency-file))
  (setq rustic-lsp-server 'rust-analyzer))

(after! lsp
  ;; disable the eldoc stuff
  (setq lsp-eldoc-hook nil)
  (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-rust-analyzer-cargo-watch-command "remote -h check --")
  (setq lsp-rust-analyzer-use-client-watching nil)
)

(setq display-line-numbers-type 'relative)

(setq show-trailing-whitespace t)

;; Enable global whitespace mode
(global-whitespace-mode 1)

(add-hook 'diff-mode-hook 'whitespace-mode)

(setq whitespace-style '(face tabs tab-mark spaces space-mark trailing lines-tail))


;; Make flycheck use direnv to get the correct env for finding an executable
(setq flycheck-executable-find
     (lambda (cmd) (direnv-update-environment default-directory)(executable-find cmd)))

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