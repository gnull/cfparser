(defun cf-login (uname psswd remember)
  (setq cf-response 
	(shell-command-to-string
	 (format "curl --silent --cookie-jar %s '%s://%s/enter'"
		 cf-cookies-file
		 cf-proto cf-host)))
  (string-match "name='csrf_token' +value='\\([^\']+\\)'" cf-response)
  (setq cf-csrf-token (match-string 1 cf-response))
  (setq cf-response
	(shell-command-to-string 
	 (format "curl --location --silent --cookie-jar %s --data 'action=enter&handle=%s&password=%s&remember=%s&csrf_token=%s' '%s://%s/enter'"
		 cf-cookies-file
		 uname psswd remember cf-csrf-token
		 cf-proto cf-host))
	)
  (if (string-match "\"error for__password\"" cf-response)
      '"login: fail [wrong password?]"
    '"login: ok"))

(defun cf-login-read() 
  (let ((cf-uname (read-string "usename: "))
	(cf-psswd (read-passwd "password: "))
	(cf-remember (if (y-or-n-p "remember? ") '"on" '"")))
    (message 
     (cf-login cf-uname cf-psswd cf-remember))))

(defun cf-logout ()
  (delete-file cf-cookies-file))



(progn
  (setq cf-host "codeforces.ru")
  (setq cf-proto "http")
  (setq cf-cookies-file "~/.cf-cookies")
  (cf-logout)
  (cf-login-read))
