(load "cf-main.el")

(defun cf-login-i()
  (interactive)
  (let ((cf-uname (read-string "usename: "))
	(cf-psswd (read-passwd "password: "))
	(cf-remember (if (y-or-n-p "remember? ") '"on" '"")))
    (message
     (if (cf-login cf-uname cf-psswd cf-remember)
	 '"login: ok"
       '"login: fail"))))

(defun cf-logout-i()
  (interactive)
  (cf-logout)
  (message "logout: ok"))

(defun cf-whoami-i()
  (interactive)
  (message (format "logged in as %s" (cf-logged-in-as))))

(defun cf-submit-current-buffer-by-path-i()
  (interactive)
  (unless (cf-logged-in-as)
    (cf-login-i))
  (let (contest problem extension language path)
    (setq path (buffer-file-name))
    (if (string-match "/\\([0-9]+\\)/?\\([a-zA-Z0-9]\\)\\(\.[^.]+\\)$" path)
	(progn
	  (setq contest (match-string 1 path))
	  (setq problem (match-string 2 path))
	  (setq extension (match-string 3 path))
	  (setq language
		(cond
		 ((string= extension ".cpp") cf-pl-g++)
		 ((string= extension ".cc") cf-pl-g++)
		 ((string= extension ".c") cf-pl-gcc)
		 ((string= extension ".pas") cf-pl-fpc)
		 ((string= extension ".php") cf-pl-php)
		 ((string= extension ".java") cf-pl-java-7)
		 ;; and so on..
		 (t cf-default-language)))
	  (message
	   (if (cf-submit contest problem (buffer-substring-no-properties (buffer-end -1) (buffer-end 1)) language)
	       (format "submit: ok [by %s to %s/%s]" (cf-logged-in-as) contest problem)
	     '"submit: fail")))
      (message "submit: file name not recognized"))))

(global-set-key (kbd "C-c s") 'cf-submit-current-buffer-by-path-i)
(global-set-key (kbd "C-c i") 'cf-login-i)
(global-set-key (kbd "C-c o") 'cf-logout-i)
(global-set-key (kbd "C-c w") 'cf-whoami-i)

