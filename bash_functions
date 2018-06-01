basedir="/mnt/d"
WORKDIR="$basedir/Projects"
CERTDIR="$basedir/certification"
CXAPDIR="$basedir/cxap"


complete -F _work_completer work
complete -W '$(ls $CXAPDIR)'   cxap

alias cdw='cd ~1'

function _work_completer {
  dir=$WORKDIR
  for name in ${COMP_WORDS[@]}
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  COMPREPLY=( $(compgen -W '$(ls $dir)' -- "${COMP_WORDS[$COMP_CWORD]}") )

  return 0
}

function work {
  if [ -e $WORKDIR/$1 ]; then
    pushd $WORKDIR/$1
  fi
}

function mm {
  deep=${#DIRSTACK[@]}
  if [ $deep -gt 1 ]; then
    popd
  fi
}

function cert {
  if [ -e $CERTDIR/$1 ]; then
    pushd $CERTDIR/$1
  fi
}

function cxap {
  if [ -e $CXAPDIR/$1 ]; then
    pushd $CXAPDIR/$1
  fi
}

function windo {
  bs=${1//\//\\}
  echo Running: $bs
  cmd.exe /c "$bs" ${@:2}
}

calc(){ awk "BEGIN{ print $* }" ;}


# format with clang-format before adding to git
validFiletypes="c|h|cpp|hpp|js"
function gitadd {
  cur=0
  argArray=( "$@" )
  while [[ $cur -lt $# ]]; do
    if [[ ${argArray[$cur]} =~ \.($validFiletypes)$ ]]; then
      clang-format -i -style=file ${argArray[$cur]}
    else
      echo Not clang-format compatible: ${argArray[$cur]}
    fi
    git add -v ${argArray[$cur]}
    cur=$(($cur + 1))
  done
}
