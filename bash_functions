
basedir="/mnt/d"
WORKDIR="$basedir/Projects"
CERTDIR="$basedir/certification"
CXAPDIR="$basedir/cxap"


complete -F _work_completer work
complete -F _cert_completer cert
complete -W "$(ls $CXAPDIR)"   cxap

alias cdw='cd ~1'

function _work_completer {
  dir=$WORKDIR
  for name in "${COMP_WORDS[@]}"
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  COMPREPLY=( $(compgen -W "$(ls "$dir")" -- "${COMP_WORDS[$COMP_CWORD]}") )

  return 0
}

function _cert_completer {
  dir=$CERTDIR
  for name in "${COMP_WORDS[@]}"
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  COMPREPLY=( $(compgen -W "$(ls "$dir")" -- "${COMP_WORDS[$COMP_CWORD]}") )

  return 0
}

function work {
  dir=$WORKDIR
  for arg in "$@"
  do
    dir=$dir/$arg
  done

  if [ -d $dir ]; then
    pushd $dir
  fi
}

function mm {
  deep="${#DIRSTACK[@]}"
  if [ "$deep" -gt 1 ]; then
    popd
  fi
}

function cert {
  dir=$CERTDIR
  for arg in "$@"
  do
    dir=$dir/$arg
  done

  if [ -d $dir ]; then
    pushd $dir
  fi
}

function cxap {
  dir=$CXAPDIR
  for arg in "$@"
  do
    dir=$dir/$arg
  done

  if [ -d $dir ]; then
    pushd $dir
  fi
}

function windo {
  bs="${1//\//\\}"
  echo "Running: $bs"
  cmd.exe /c "$bs" "${@:2}"
}

function explore {
  bs="${1//\//\\}"

  if [[ -z $bs ]]; then
    bs='.'
  fi

  windo explorer "$bs"
}

calc(){ awk "BEGIN{ print $* }" ;}


# format with clang-format before adding to git
validFiletypes="c|h|cpp|hpp|js|pl|pm"
function gitadd {
  cur=0
  argArray=( "$@" )
  while [[ $cur -lt $# ]]; do
    if [[ ${argArray[$cur]} =~ \.($validFiletypes)$ ]]; then
      filename=${argArray[$cur]}
      case ${filename##*.} in
        p[lm])
          perltidy -b -nst "$filename"
          ;;
        *)
        clang-format -i -style=file "${argArray[$cur]}"
        ;;
      esac  
    else
      echo "No formatter specified: ${argArray[$cur]}"
    fi

    git add -v "${argArray[$cur]}"
    cur=$((cur + 1))
  done
}

function h {
  results=$(history)

  for arg in "$@"
  do
    results=$(echo "$results" | grep "$arg")
  done

  echo "$results"
}

NORMAL="\033[m"        # White
RED_TEXT="\033[31m"    # Red
GREEN_TEXT="\033[32m"  # Green

function white {
  printf "${NORMAL}" 
}

function red {
  printf "${RED_TEXT}" 
}

function green {
  printf "${GREEN_TEXT}" 
}


function windir {
  bs=$1
  if [[ $1 == '.' ]]; then
    bs=$(pwd)
  fi  

  if [[ $1 == '~' ]]; then
    echo 'C:\Users\Andrew Pressel'
    return
  fi  

  if [[ $bs != /mnt/* ]]; then
    echo not a windows directory
    return
  fi   

  bs="${bs//\/mnt\/d\//D:\\}"
  bs="${bs//\/mnt\/c\//C:\\}"

  bs="${bs//\//\\}"
  echo $bs  
}


