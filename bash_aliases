alias reload='source $HOME/.bashrc'

#====[ basics ]=============================================
alias rm='rm -i'
alias cp='cp -i'
alias less='less -R'

#====[ directory listing ]==================================
alias ll='ls -lrt'
alias la='ls -A'
alias lisa='ls -lisart'

#====[ vim ]================================================
alias vir='vim -R'

#====[ search ]=============================================
alias findinfiles="find . -type f -not -path \"*/.git/*\" 2> /dev/null | xargs -d '\n' grep"

#====[ miscellaneous ]======================================
alias junk='vi /tmp/junk.amp'
alias mine='ps -eaf | grep $USER'
#alias h='history | grep'
alias r='fc -s '
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

#====[ WSL ]================================================
alias powershell='cmd.exe /c start powershell'
alias st='cmd.exe /c "C:\Users\Andrew Pressel\AppData\Local\SourceTree\SourceTree.exe"'
alias snip='windo SnippingTool.exe &'
alias dbeaver='windo "C:\Program Files\DBeaver\dbeaver.exe" -nl en'
alias pm='windo "C:\Users\Andrew Pressel\AppData\Local\Postman\Update.exe" --processStart "Postman.exe"'

#====[ docker ]=============================================
alias dstop='docker stop $(docker ps -q)'
alias dnostart='docker update --restart=no $(docker ps --all -q)'
alias dclean='docker rmi -f $(docker images -f "dangling=true" -q)'
alias dlogin='ln -s ~/.docker/config.json.keep ~/.docker/config.json'
alias dlogout='rm -f ~/.docker/config.json'

