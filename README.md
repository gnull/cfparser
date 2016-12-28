# cfparser

Emacs plugin for participating in http://codeforces.com programming competitions.

## Installation
- Install `curl`
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
- `cf-default-language` - language to be used when it was not recognized by extension
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

  In file `cf-languages.el` you can adjust extension-to-language mappings.
## Using
- `C-c c w` - **W**ho am I
- `C-c c s` - **S**ubmit currently open file
- `C-c c i` - Log **I**n
- `C-c c o` - Log **O**ut
- `C-c c d` - **D**ownload sample tests to current folder (0.in, 0.ans, 1.in ...)
- `C-c c t` - Execute `cf-`**t**`est-command`
- `C-c c l` - **L**ist most recent submissions

Submit and save functions "guess" the contest number, problem index and the programming language by the current file name in one of the following forms:
- `directory/505/A/myfile.cpp`
- `directory/505/a.c`
- `directory/505a.cc`

## See also

 - [gabrielsimoes/cfparser.vim](https://github.com/gabrielsimoes/cfparser.vim) -- Similar plugin for *Vim*. It has more features than this one (e.g it can display a problem statement).
