(load "cf-languages.el")

(setq cf-default-language cf-pl-g++)
(setq cf-host "codeforces.com")
(setq cf-proto "http")
(setq cf-cookies-file "~/.cf-cookies")

(defun cf-get-csrf-token(page)
  (string-match "name='csrf_token' +value='\\([^\']+\\)'" page)
  (match-string 1 page))

(defun cf-logged-in-as ()
  (setq cf-response
	(shell-command-to-string
	 (format "curl --silent --cookie-jar %s --cookie %s '%s://%s/' "
		 cf-cookies-file cf-cookies-file
		 cf-proto cf-host)))
  (when (string-match "<a href=\"/[a-z0-9]*/logout\">" cf-response)
    (string-match "<a href=\"/profile/\\([^\"]*\\)\">" cf-response)
    (match-string 1 cf-response)))

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
      'nil
    't))

(defun cf-submit(contest problem solution language)
  (setq cf-csrf-token
	(cf-get-csrf-token
	 (shell-command-to-string
	  (format "curl --silent --cookie-jar %s --cookie %s '%s://%s/contest/%s/submit'"
		  cf-cookies-file cf-cookies-file
		  cf-proto cf-host contest))))

  (setq temp-file (make-temp-file "cfparser"))
  (with-temp-file temp-file (insert solution))

  (setq cf-response
	(shell-command-to-string
	 (format
	  "curl --location --silent --cookie-jar %s --cookie %s -F 'csrf_token=%s' -F 'action=submitSolutionFormSubmitted' -F 'submittedProblemIndex=%s' -F 'programTypeId=%s' -F \"source=@%s\" '%s://%s/contest/%s/submit?csrf_token=%s'"
	  cf-cookies-file cf-cookies-file
	  cf-csrf-token
	  problem
	  language temp-file
	  cf-proto cf-host contest cf-csrf-token
	  ))))

(defun cf-parse-tests(page)
  (let ((input_regex  "<div class=\"input\">.*?<pre>\\(.*?\\)</pre></div>")
	(output_regex "<div class=\"output\">.*?<pre>\\(.*?\\)</pre></div>")
	(from 0)
	(input "")
	(output "")
	(result '()))
    (while (setq from (string-match input_regex page from))
      (setq input (match-string 1 page))
      (setq from (string-match output_regex page from))
      (setq output (match-string 1 page))
      (setq input (replace-regexp-in-string "<br[^>]*?>" "\n" input))
      (setq output (replace-regexp-in-string "<br[^>]*?>" "\n" output))
      (push (list input output) result))
    result))

(defun cf-get-tests(contest problem)
  (setq cf-response
	(shell-command-to-string
	 (format "curl --silent --cookie-jar %s --cookie %s '%s://%s/contest/%s/problem/%s'"
		 cf-cookies-file cf-cookies-file
		 cf-proto cf-host contest problem)))
  (cf-parse-tests cf-response))

(defun cf-logout ()
  (when (file-exists-p cf-cookies-file)
    (delete-file cf-cookies-file)))

