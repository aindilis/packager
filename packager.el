;; Packager : Packaging Tool

;; (defun dired-do-shell-command (command &optional arg file-list)
;;  (interactive
;;   (let ((files (dired-get-marked-files t current-prefix-arg)))
;;    (list
;;     ;; Want to give feedback whether this file or marked files are used:
;;     (dired-read-shell-command (concat "! on "
;; 			       "%s: ")
;;      current-prefix-arg
;;      files)
;;     current-prefix-arg
;;     files)))
;;  (let* ((on-each (not (string-match "\\*" command))))
;;   (if on-each
;;    (dired-bunch-files
;;     (- 10000 (length command))
;;     (function (lambda (&rest files)
;; 	       (dired-run-shell-command
;; 		(dired-shell-stuff-it command files t arg))))
;;     nil
;;     file-list)
;;    ;; execute the shell command
;;    (dired-run-shell-command
;;     (dired-shell-stuff-it command file-list nil arg)))))
