alias reload='source $HOME/.bash/bashrc'

#====[ basics ]=============================================
alias rm='rm -i'
alias cp='cp -i'
alias less='less -R'

#====[ directory listing ]==================================
alias ll='ls -lrt'
alias la='ls -Alrt'
alias lisa='ls -lisart'

#====[ editors ]============================================
alias vir='vim -R'
alias idea='idea64.exe . &'


#====[ miscellaneous ]======================================
alias bok='vi ${HOME}/.bok'
alias junk='vi /tmp/junk.amp'
alias diff='colordiff'
alias cpptidy='clang-format -i'
alias cprofile='valgrind --tool=callgrind'
alias cat='batcat --paging=never'


#====[ GIT ]================================================
alias git.junk='git ls-files --others --exclude-standard'

#====[ bindechexascii ]=====================================
alias b2d='bindechexascii --b2d'
alias b2h='bindechexascii --b2h'
alias d2b='bindechexascii --d2b'
alias d2h='bindechexascii --d2h'
alias h2b='bindechexascii --h2b'
alias h2d='bindechexascii --h2d'
