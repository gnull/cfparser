(load "cf-main.el")

(defun cf-login-i()
  "Login to Codeforces using handle/password."
  (interactive)
  (let ((cf-uname (read-string "usename: "))
	(cf-psswd (read-passwd "password: "))
	(cf-remember (if (y-or-n-p "remember? ") '"on" '"")))
    (message
     (if (cf-login cf-uname cf-psswd cf-remember)
	 '"login: ok"
       '"login: fail"))))

(defun cf-logout-i()
  "Logout from Codeforces."
  (interactive)
  (cf-logout)
  (message "logout: ok"))

(defun cf-whoami-i()
  "Print handle."
  (interactive)
  (message (format "logged in as %s" (cf-logged-in-as))))

(setq cf-path-regexp "/\\([0-9]+\\)/?\\([a-zA-Z]\\)/?[^/.]*\\(\.[^.]+\\)$")
(defun cf-submit-current-buffer-by-path-i()
  "Submit contents of the buffer."
  (interactive)
  (unless (cf-logged-in-as)
    (cf-login-i))
  (let (contest problem extension language path)
    (setq path (buffer-file-name))
    (if (string-match cf-path-regexp path)
	(progn
	  (setq contest (match-string 1 path))
	  (setq problem (match-string 2 path))
	  (setq extension (match-string 3 path))
	  (setq language (gethash extension cf-pl-by-ext))
	  (unless language 
	    (setq language cf-default-language))
	  (message
	   (if (cf-submit contest problem (buffer-substring-no-properties (buffer-end -1) (buffer-end 1)) language)
	       (format "submit: ok [by %s to %s/%s]" (cf-logged-in-as) contest problem)
	     '"submit: fail")))
      (message "submit: file name not recognized"))))

(defun cf-download-tests-i() 
  "Save sample tests to the current directory. 0.in, 0.ans, 1.in ..."
  (interactive)
  (let (tests input output contest problem path i)
    (setq path (buffer-file-name))
    (if (string-match cf-path-regexp path)
	(progn
	  (setq contest (match-string 1 path))
	  (setq problem (match-string 2 path))
	  (message (format "downloading tests for %s/%s..." contest problem))
	  (setq tests (cf-get-tests contest problem))
	  (setq i 0)
	  (dolist (test tests)
	    (setq input (car test))
	    (setq output (cadr test))
	    (with-temp-buffer
	      (insert input)
	      (write-region (point-min) (point-max) (format "%d.in" i))
	      (erase-buffer)
	      (insert output)
	      (write-region (point-min) (point-max) (format "%d.out" i)))
	    (setq i (+ 1 i)))
	  (message (format "downloaded %d tests" i)))
      (message "download: file name not recognized"))))

(define-minor-mode cf-mode
  "Minor mode of codeforces parser"
  :lighter " Codeforces"
  :keymap (list
	   (cons (kbd "C-c c w") 'cf-whoami-i)
	   (cons (kbd "C-c c s") 'cf-submit-current-buffer-by-path-i)
	   (cons (kbd "C-c c i") 'cf-login-i)
	   (cons (kbd "C-c c o") 'cf-logout-i)
	   (cons (kbd "C-c c w") 'cf-whoami-i)
	   (cons (kbd "C-c c t") 'cf-test-all-i)
       (cons (kbd "C-c c d") 'cf-download-tests-i)
       (cons (kbd "C-c c l") 'cf-last-submissions-i))

(setq cf-test-command nil)
(defun cf-test-all-i()
  (interactive)
  (if cf-test-command
      (compile cf-test-command)
    (message "Please set cf-test-command")))

(defun cf-last-submissions-i()
  (interactive)
  (with-output-to-temp-buffer "*cf-lastsubmissions*"
    (setq v (cf-submission-vector (cf-logged-in-as)))
    (dotimes (i (length v))
      (setq subinfo (elt v i))
      (setq probinfo (cdr (assoc '"problem" subinfo)))
        (princ (format "%d%s - %s - %s - Last Test: %d - %dkB - %dms - %d pts\n"
                        (cdr (assoc '"contestId" probinfo))
                        (cdr (assoc '"index" probinfo))
                        (cdr (assoc '"name" probinfo))
                        (cdr (assoc '"verdict" subinfo))
                        (cdr (assoc '"passedTestCount" subinfo))
                        (/ (cdr (assoc '"memoryConsumedBytes" subinfo)) 1000)
                        (cdr (assoc '"timeConsumedMillis" subinfo))
                        (cdr (assoc '"points" probinfo)))))))
(provide 'cf-mode)
