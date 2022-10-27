source "${HOME}/bin/common.sh"

basedir="${WORKSPACE_DIR}"
WORKDIR="${basedir}/projects"
CERTDIR="${basedir}/certification"
CXAPDIR="${basedir}/cxap"
EXPERDIR="${basedir}/experiment"


complete -F _work_completer work
complete -F _cert_completer cert
complete -F _exp_completer  exp
complete -F _cxap_completer cxap

alias cdw='cd ~1'


function exp {
  dir=$EXPERDIR
  for arg in "$@"
  do
    dir="${dir}/${arg}"
  done

  if [ -d "${dir}" ]; then
    pushd "${dir}" || return
  fi
}

function _exp_completer {
  dir=$EXPERDIR
  for name in "${COMP_WORDS[@]:1}"
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  mapfile -t dirs < <(find "${dir}" -maxdepth 1 -type d)
  mapfile -t dirs < <(for f in "${dirs[@]:1}"; do basename "${f}"; done)
  mapfile -t COMPREPLY < <(compgen -W "${dirs[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")

  return 0
}

function _work_completer {
  dir=$WORKDIR
  for name in "${COMP_WORDS[@]:1}"
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  mapfile -t dirs < <(find "${dir}" -maxdepth 1 -type d)
  mapfile -t dirs < <(for f in "${dirs[@]:1}"; do basename "${f}"; done)
  mapfile -t COMPREPLY < <(compgen -W "${dirs[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")

  return 0
}

function _cert_completer {
  dir=$CERTDIR
  for name in "${COMP_WORDS[@]:1}"
  do
    if [ -d "$dir/$name" ]; then
      dir=$dir/$name
    fi
  done

  mapfile -t dirs < <(find "${dir}" -maxdepth 1 -type d)
  mapfile -t dirs < <(for f in "${dirs[@]:1}"; do basename "${f}"; done)
  mapfile -t COMPREPLY < <(compgen -W "${dirs[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")

  return 0
}

function work {
  dir=$WORKDIR
  for arg in "$@"
  do
    dir=${dir}/${arg}
  done

  if [ -d "${dir}" ]; then
    pushd "${dir}" || return
  fi
}


function mm {
  deep="${#DIRSTACK[@]}"
  if [ "${deep}" -gt 1 ]; then
    popd || return
  fi
}


function cert {
  dir=$CERTDIR
  for arg in "$@"
  do
    dir=${dir}/${arg}
  done

  if [ -d "${dir}" ]; then
    pushd "${dir}" || return
  fi
}

function cxap {
  dir=$CXAPDIR
  for arg in "$@"
  do
    dir="${dir}/${arg}"
  done

  if [ -d "${dir}" ]; then
    pushd "${dir}" || return
  fi
}

function _cxap_completer {
  dir=$CXAPDIR
  for name in "${COMP_WORDS[@]:1}"
  do
    if [ -d "$dir/$name" ]; then
      dir="$dir/$name"
    fi
  done

  mapfile -t dirs < <(find "${dir}" -maxdepth 1 -type d)
  mapfile -t dirs < <(for f in "${dirs[@]:1}"; do basename "${f}"; done)
  mapfile -t COMPREPLY < <(compgen -W "${dirs[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")

  return 0
}

function windo {
  bs="$1" 
  if [[ -f "${bs}" ]]; then
    bs='\\wsl$\Ubuntu'$(readlink -f "${bs}")
  fi

  bs="${bs//\//\\}"
  echo "Running: $bs"
  cmd.exe /c "$bs" "${@:2}"
}

function explore {
  bs="$1"

  if [[ -z $bs ]]; then
    bs=$(readlink -f .)
  fi

  windo explorer '\\wsl$\Ubuntu'"${bs//\//\\}"
}

calc(){ awk "BEGIN{ print $* }" ;}


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
  printf '%s' "${NORMAL}"
}

function red {
  printf '%s' "${RED_TEXT}"
}

function green {
  printf '%s' "${GREEN_TEXT}"
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
  echo "$bs"
}

function s3touch () {

  fileUri=
  if [[ $# == 1 ]]; then
    fileUri=$1
  elif [[ $# == 2 ]]; then
    fileUri="s3://$1/$2"
  else
    message_error "Invalid file specified"
    return 1
  fi

  echo "FileUri:[${fileUri}]"
  aws s3 cp "${fileUri}" "${fileUri}" --metadata '{"x-amz-metadata-directive":"REPLACE"}'
}

function r () {
  for cmd in "$@"
  do
    fc -s "${cmd}"
  done
}
