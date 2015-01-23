(load-file "languages.el")

(setq cf-default-language cf-pl-g++)
(setq cf-host "codeforces.ru")
(setq cf-proto "http")
(setq cf-cookies-file "~/.cf-cookies")

(defun cf-get-csrf-token(page)
  (string-match "name='csrf_token' +value='\\([^\']+\\)'" page)
  (match-string 1 page))

(defun cf-login (uname psswd remember)
  (setq cf-response
	(shell-command-to-string
	 (format "curl --silent --cookie-jar %s '%s://%s/enter'"
		 cf-cookies-file
		 cf-proto cf-host)))
  (setq cf-csrf-token (cf-get-csrf-token cf-response))
  (setq cf-response
	(shell-command-to-string
	 (format "curl --location --silent --cookie-jar %s --cookie %s --data 'action=enter&handle=%s&password=%s&remember=%s&csrf_token=%s' '%s://%s/enter'"
		 cf-cookies-file cf-cookies-file
		 uname psswd remember cf-csrf-token
		 cf-proto cf-host))
	)
  (if (string-match "\"error for__password\"" cf-response)
      '"login: fail [wrong password?]"
    '"login: ok"))

(defun cf-submit(contest problem solution)
  (setq cf-csrf-token
	(cf-get-csrf-token
	 (shell-command-to-string
	  (format "curl --silent --cookie-jar %s --cookie %s '%s://%s/contest/%s/submit'"
		  cf-cookies-file cf-cookies-file
		  cf-proto cf-host contest))))
  (setq cf-response
	(shell-command-to-string
	 (format
	  "curl --location --silent --cookie-jar %s --cookie %s -F 'csrf_token=%s' -F 'action=submitSolutionFormSubmitted' -F 'submittedProblemIndex=%s' -F 'programTypeId=%s' -F 'source=%s' '%s://%s/contest/%s/submit?csrf_token=%s'"
	  cf-cookies-file cf-cookies-file
	  cf-csrf-token
	  problem
	  cf-default-language solution
	  cf-proto cf-host contest cf-csrf-token
	  ))))

(defun cf-login-read() 
  (let ((cf-uname (read-string "usename: "))
	(cf-psswd (read-passwd "password: "))
	(cf-remember (if (y-or-n-p "remember? ") '"on" '"")))
    (message 
     (cf-login cf-uname cf-psswd cf-remember))))

(defun cf-logout ()
  (when (file-exists-p cf-cookies-file)
    (delete-file cf-cookies-file)))

