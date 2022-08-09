# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


if [[ -z ${WORKSPACE_DIR} ]]; then
  echo "WORKSPACE_DIR must be configured; not continuing"
  return
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set vi editing mode on the commandline
set -o vi
export EDITOR='/usr/bin/nvim'

# set pipes to cascade fail 
set -o pipefail

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#    xterm-color|*-256color) color_prompt=yes;;
#esac

#color_prompt='no'
#if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# We have color support; assume it's compliant with Ecma-48
# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# a case would tend to support setf rather than setaf.)
#	color_prompt='yes'
#fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#PS1="\$(term_git_title)\[\033[38;5;226m\]\u\[$(tput sgr0)\]\[\033[38;5;6m\][\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;15m\]\W\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;6m\]]:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if [[ -r ~/.dircolors ]]; then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash/aliases_bash, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "${HOME}/.bash/aliases.bash" ]; then
    . "${HOME}/.bash/aliases.bash"
fi

#====[ custom functions ]===================================
if [ -f "${HOME}/.bash/functions.bash" ]; then
    . "${HOME}/.bash/functions.bash"
fi

#====[ type plugins ]=======================================
plugins=('ftplugin' 'projects')
for plug_dir in "${plugins[@]}"
do
  if [[ -d "${HOME}/.bash/${plug_dir}" ]]; then
    mapfile -t projects < <(find "${HOME}/.bash/${plug_dir}" -type f -name '*.bash');
    for file in "${projects[@]}"
    do
      # echo "loading [${file}]"
      . "${file}"
    done
  fi
done

#====[ X11 ]================================================
hostname=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null)
export DISPLAY="${hostname}:0"


# set PATH so it includes user's private bin directories
PATH=".:$HOME/bin:$HOME/.local/bin:$PATH"


# Load Angular CLI autocompletion.
source <(ng completion script)
