source "${HOME}/bin/common.sh"

basedir="${WORKSPACE_DIR}"
WORKDIR="${basedir}/projects"
CERTDIR="${basedir}/certification"

function windo {
  bs="$1" 
  if [[ -f "${bs}" ]]; then
    bs="\\\\wsl\$\\${WSL_DISTRO_NAME}"$(readlink -f "${bs}")
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

  windo explorer '\\wsl$\Ubuntu-22.04'"${bs//\//\\}"
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

function fp {
  results=$(apt list)

  for arg in "$@"
  do
    results=$(echo "$results" | grep "$arg")
  done

  echo "$results"
}
