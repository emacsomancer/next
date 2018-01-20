;;;; base.lisp --- main entry point into nEXT

(in-package :next)

(defun start ()
  (ensure-directories-exist (xdg-data-home))
  (initialize-default-key-bindings)
  ;; load the user configuration if it exists
  (load *init-file-path* :if-does-not-exist nil)
  (initialize-bookmark-db)
  (initialize-history-db)
  (interface:initialize)
  (interface:start)
  ;; create the default buffers
  (setf *minibuffer*
        (make-instance 'buffer :name "minibuffer" :mode (minibuffer-mode)))
  (set-visible-active-buffer (generate-new-buffer "default" (document-mode)))
  (set-url *start-page-url*))

(defun initialize-default-key-bindings ()
  (define-key *global-map* (kbd "C-x C-c")
    'interface:kill)
  (define-key *global-map* (kbd "C-x b")
    (:input-complete *minibuffer* switch-buffer buffer-complete))
  (define-key *global-map* (kbd "C-x k")
    (:input-complete *minibuffer* delete-buffer buffer-complete))
  (define-key *global-map* (kbd "M-l")
    (:input-complete *minibuffer* set-url-new-buffer history-typed-complete :empty-complete t))
  (define-key *global-map* (kbd "S-b k")
    (:input-complete *minibuffer* bookmark-delete bookmark-complete))
  (define-key *minibuffer-mode-map* (kbd "RETURN")
    #'(lambda () (return-input (mode *minibuffer*))))
  (define-key *minibuffer-mode-map* (kbd "C-RETURN")
    #'(lambda () (return-immediate (mode *minibuffer*))))
  (define-key *minibuffer-mode-map* (kbd "C-g")
    #'(lambda () (cancel-input (mode *minibuffer*))))
  (define-key *minibuffer-mode-map* (kbd "Escape")
    #'(lambda () (cancel-input (mode *minibuffer*))))
  (define-key *document-mode-map* (kbd "M-f")
    (:input-complete *minibuffer* history-forwards-query history-fowards-query-complete))
  (define-key *document-mode-map* (kbd "M-b")
    'history-backwards)
  (define-key *document-mode-map* (kbd "C-g")
    (:input *minibuffer* go-anchor :setup 'setup-anchor :cleanup 'remove-link-hints))
  (define-key *document-mode-map* (kbd "M-g")
    (:input *minibuffer* go-anchor-new-buffer :setup 'setup-anchor :cleanup 'remove-link-hints))
  (define-key *document-mode-map* (kbd "S-g")
    (:input *minibuffer* go-anchor-new-buffer-focus :setup 'setup-anchor))
  (define-key *document-mode-map* (kbd "C-f")
    'history-forwards)
    ;; 'scroll-right)
  (define-key *document-mode-map* (kbd "C-b")
    'history-backwards)
    ;; 'scroll-left)
  (define-key *document-mode-map* (kbd "C-p")
    'scroll-up)
  (define-key *document-mode-map* (kbd "C-n")
    'scroll-down)
  (define-key *document-mode-map* (kbd "C-x C-=")
    'zoom-in-page)
  (define-key *document-mode-map* (kbd "C-x C-HYPHEN")
    'zoom-out-page)
  (define-key *document-mode-map* (kbd "C-x C-0")
    'unzoom-page)
  (define-key *document-mode-map* (kbd "C-l")
    (:input-complete *minibuffer* set-url history-typed-complete :setup 'setup-url :empty-complete t))
  (define-key *document-mode-map* (kbd "S-b o")
    (:input-complete *minibuffer* set-url bookmark-complete))
  (define-key *document-mode-map* (kbd "S-b s")
    'bookmark-current-page)
  (define-key *document-mode-map* (kbd "S-b g")
    (:input *minibuffer* bookmark-anchor :setup 'setup-anchor :cleanup 'remove-link-hints))
  (define-key *global-map* (kbd "S-b u")
    (:input *minibuffer* bookmark-url))
  (define-key *document-mode-map* (kbd "C-[")
    'switch-buffer-previous)
  (define-key *document-mode-map* (kbd "C-]")
    'switch-buffer-next)
  (define-key *global-map* (kbd "C-x w")
    'delete-active-buffer)
  (define-key *minibuffer-mode-map* (kbd "C-n")
    'interface:minibuffer-select-next)
  (define-key *minibuffer-mode-map* (kbd "C-p")
    'interface:minibuffer-select-previous)
  (define-key *global-map* (kbd "S-h v")
    (:input-complete *minibuffer* variable-inspect variable-complete :setup 'load-package-globals))
  (define-key *global-map* (kbd "C-o")
    (:input *minibuffer* load-file))
  (define-key *global-map* (kbd "S-h s")
    'start-swank)
  (define-key *document-mode-map* (kbd "S-s s")
    (:input *minibuffer* add-search-boxes :setup 'initialize-search-buffer))
  (define-key *document-mode-map* (kbd "S-s n")
    'next-search-hint)
  (define-key *document-mode-map* (kbd "S-s p")
    'previous-search-hint)
  (define-key *document-mode-map* (kbd "S-s k")
    'remove-search-hints)
  (define-key *document-mode-map* (kbd "C-.")
    (:input-complete *minibuffer* jump-to-heading heading-complete :setup 'setup-headings-jump))
  (define-key *global-map* (kbd "C-y")
    'interface:paste)
  (define-key *global-map* (kbd "C-w")
    'interface:cut)
  (define-key *global-map* (kbd "M-w")
    'interface:copy)
  (define-key *document-mode-map* (kbd "M->")
    'scroll-to-bottom)
  (define-key *document-mode-map* (kbd "M-<")
    'scroll-to-top))
