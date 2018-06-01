alias reload='source $HOME/.bashrc'

#====[ basics ]=============================================
alias rm='rm -i'
alias cp='cp -i'
alias less='less -R'

#====[ directory listing ]==================================
alias ll='ls -lrt'
alias la='ls -A'
alias lisa='ls -lisart'

#====[ search ]=============================================
alias findinfiles='find . -type f | xargs grep'

#====[ miscellaneous ]======================================
alias junk='vi /tmp/junk.amp'
alias mine='ps -eaf | grep $USER'
alias h='history | grep'
alias diff='colordiff'
alias cpptidy='clang-format -i'

