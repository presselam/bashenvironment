alias reload='source $HOME/.bashrc'

#====[ basics ]=============================================
alias rm='rm -i'
alias cp='cp -i'
alias less='less -R'

#====[ directory listing ]==================================
alias ll='ls -lrt'
alias la='ls -A'
alias lisa='ls -lisart'

#====[ editors ]============================================
alias vir='vim -R'
alias idea='idea64.exe . &'

#====[ search ]=============================================
alias fif="find . -type f -not -path \"*/.git/*\" 2> /dev/null | xargs -d '\n' grep"
alias ff="find . -type f -not -path \"*/.git/*\" -name "
alias fd="find . -type d -not -path \"*/.git/*\" -name "

#====[ miscellaneous ]======================================
alias bok='vi ${HOME}/.bok'
alias junk='vi /tmp/junk.amp'
alias mine='ps -eaf | grep $USER'
alias diff='colordiff'
alias cpptidy='clang-format -i'
alias cprofile='valgrind --tool=callgrind'

#====[ GIT ]================================================
alias git.junk='git ls-files --others --exclude-standard'

#====[ bindechexascii ]=====================================
alias b2d='bindechexascii --b2d'
alias b2h='bindechexascii --b2h'
alias d2b='bindechexascii --d2b'
alias d2h='bindechexascii --d2h'
alias h2b='bindechexascii --h2b'
alias h2d='bindechexascii --h2d'


alias kube='kubectl'
source <(kubectl completion bash)
complete -F __start_kubectl kube
source /opt/istio-1.13.2/tools/istioctl.bash

