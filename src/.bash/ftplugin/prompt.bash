#!/bin/bash

userPlate="$(tput setab 234)$(tput setaf 91)$(tput bold)"
dirPlate="$(tput setab 235)$(tput setaf 255)"
branchPlate="$(tput setab 237)$(tput setaf 255)$(tput bold)"
statusPlate="$(tput setab 239)$(tput setaf 255)$(tput bold)"

trans_dir="$(tput setab 235)$(tput setaf 234)"
trans_git="$(tput setab 237)$(tput setaf 235)"
trans_status="$(tput setab 239)$(tput setaf 237)"
trans_prompt="$(tput sgr0)$(tput setaf 239)"

function _prompt_git_status {
  # wsl2 hack
  git='/usr/bin/git'
  if [[ $PWD == /mnt/* ]]; then
    git="git.exe"
  fi
  
  if ${git} rev-parse --git-dir > /dev/null 2>&1; then
    status=$(git status --branch --porcelain)
    branch=$(echo "${status}" | grep --color=never '^## ' | perl -pe "s/^## ([-\w]+).*$/\1/")
    ahead=$(echo "${status}" | grep --color=never '^## ' | sed -rne  "s/^.*ahead\s*([[:digit:]]+).+$/\1/p")
    behind=$(echo "${status}" | grep --color=never '^## ' | sed -rne "s/^.*behind\s*([[:digit:]]+).+$/\1/p")
    untrack=$(echo "${status}" | grep --count --color=never '^?? ')
    staged=$(echo "${status}" | grep --count --color=never '^A ')
    modified=$(echo "${status}" | grep --count --color=never '^ M')

    printf ' \ue0a0 %s' "${branch}"
    printf ' %s\uE0B0 ' "${trans_status}"
    printf '%s' "${statusPlate}"  

    # ↓: n commits behind
    # ↑: n commits ahead
    # ●: n staged files
    # ✖: n unmerged files (conflicts)
    # ✚: n changed files
    # …: n untracked files
    # ⚑: n stashed files
    if [[ -n ${ahead} ]]; then
      echo -ne "\u2BC5${ahead} "
    fi  
    if [[ -n ${behind} ]]; then
      echo -ne "\u2BC6${behind} "
    fi  
    if [[ ${modified} -gt 0 ]]; then
      echo -ne "\u271A${modified} "
    fi  
    if [[ ${untrack} -gt 0 ]]; then
      echo -ne "…${untrack} "
    fi  
    if [[ ${staged} -gt 0 ]]; then
      echo -ne "●${staged} "
    fi  
  else
    printf '%s\uE0B0' "${trans_status}"
  fi
}




function prompt_user {
  printf '\e[6 q%s%s' "${userPlate}" "${USER}" 
  printf '%s\uE0B0' "${trans_dir}"
  printf ' %s%s ' "${dirPlate}"  "$(basename "$(dirs +0)")"
  printf '%s\uE0B0' "${trans_git}"
  printf '%s%s' "${branchPlate}"  "$(_prompt_git_status)"
  printf '%s\uE0B0' "${trans_prompt}"
}

#PS1="\[\e]0;\u@\h: \w\a\]\$(prompt_user)\[$(tput sgr0)\]\n "
PS1="\[\e]0;\u@\h: \w\a\]\$(perl $HOME/bin/prompt.pl)\[$(tput sgr0)\]\n "

