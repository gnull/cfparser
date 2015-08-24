# cfparser
Yet another codeforces parser

## Installation
 - Download cfparser
 - Add to your `~/.emacs` file the following:
```
(add-to-list 'load-path "/path/to/cfparser/")
(require 'cf-mode)
```
 - Put `cf-mode` minor mode to hook you wish. For example:
```
(add-hook 'find-file-hook 'cf-mode)  ; enable cf-mode for all open files 
```
### Optional setup
  In `~/.emacs` file you can change variables:
 - `cf-cookies-file` - file, in which `curl` will store cookies
 - `cf-test-command` - shell command to compile and run your solution on sample tests. For example:
```
(setq cf-test-command
  (concat 
    "g++ sol.cc; "
    "for i in `ls *.in | sed 's/.in//'`; do "
    "echo test $i; "
    "./a.out < $i.in | diff - $i.ans; "
    "done;"))
```

## Using
- `C-c c w` - Get current handle
- `C-c c s` - Submit currently open file
- `C-c c i` - Log in
- `C-c c o` - Log out
- `C-c c d` - Download sample tests to current folder (0.in, 0.ans, 1.in ...)
- `C-c c t` - Execute `cf-test-command`
