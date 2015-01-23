(progn
  (load-file "main.el")
  (cf-logout)
  (cf-login-read)
  (cf-submit "505" "A" "#include <cstdio>\n using namespace std;\n int main(){printf(\"Hello World!!\\n\");}"))
