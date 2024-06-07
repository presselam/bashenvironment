source "${HOME}/bin/common.sh"

#====[ docker ]=============================================
alias dstop='docker stop $(docker ps -q)'
alias dnostart='docker update --restart=no $(docker ps --all -q)'
alias dclean='docker rmi -f $(docker images -f "dangling=true" -q)'
alias dlogin='ln -s ~/.docker/config.json.keep ~/.docker/config.json'
alias dlogout='rm -f ~/.docker/config.json'

declare _dImageName
declare _dService
declare _dRegistry
declare _dVersion

function dmount {
  if [[ -z "$1" ]]; then 
    message_error "must specify a valid containerid"
    return
  fi

  resp=$(docker inspect "$1")
  echo "${resp}" | jq -r '.[].Mounts'
}

function dimage {
  args=$(getopt -o s:v:r: --long service:,version:,registry: -n dimage -aq -- "$@")

  _dRegistry='local-registry'
  _dService=$(basename "$(pwd)")
  _dVersion='0.0.0'

  if [[ -f VERSION.txt ]]; then
    _dVersion=$(cat VERSION.txt)
  fi

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -s | --service)  _dService="$2";  shift 2 ;;
      -v | --version)  _dVersion="$2";  shift 2 ;;
      -r | --registry) _dRegistry="$2"; shift 2 ;;
      --) shift; break;;
    esac
  done

  local postfix
  if [[ "${_dRegistry}" == 'local-registry' ]]; then
    postfix='-PRESSEL'
  fi

  _dImageName="${_dRegistry}/${_dService}:${_dVersion}${postfix}"
  _dImageName="${_dImageName,,}"

  caller="${FUNCNAME[1]}"
  if [[ -z ${caller} ]];then
    message_alert "Image: ${_dImageName}"
  fi
}


function dbuild {
  dimage "$@"
  args=$(getopt -o pnc:b:f: --long plain,nocache,context:,verbose,buildarg:file: -n dbuild -aq -- "$@")

  context='.'
  progress='auto'
  dfile="$(pwd)/Dockerfile"
  cache=""
  verbose=0
  declare -a buildArgs

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -p | --plain)    progress='plain'; shift   ;;
      -n | --nocache)  cache='yes';      shift   ;;
      -c | --context)  context="$2";     shift 2 ;;
      -b | --buildarg) buildArgs+=("--build-arg=$2"); shift 2;;
      -f | --file)     dfile="$2";       shift 2 ;;
      --verbose)       verbose=1;        shift   ;;
      --) shift; break;;
      *) message_error "$1 unknown"; exit;;
    esac
  done

  cmd=(docker build "${buildArgs[@]}")
  cmd+=(${cache:+--no-cache})
  cmd+=(--progress "${progress}")
  cmd+=(--tag "${_dImageName}")
  cmd+=(--file "${dfile}")
  cmd+=("${context}")

  if [[ ${verbose} == 1 ]]; then
    msg=$(printf '%s ' "${cmd[@]}")
    message "${msg}"
  fi

  "${cmd[@]}"

  message_alert "Built image: ${_dImageName}"
}

function drun {
  dimage "$@"
  args=$(getopt -o e:p:u:m: --long env:,port:,user:,mount: -n drun -aq -- "$@")

  local user
  local -a ports
  local -a mounts
  local -a envVars

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -u | --user)  user="$2";          shift 2;;
      -p | --port)  ports+=(-p "$2");   shift 2;;
      -m | --mount) mounts+=(-v "$2");  shift 2;;
      -e | --env)   envVars+=(-e "$2"); shift 2;;
      --) shift; break;;
    esac
  done

  if [[ -n "${user}" ]]; then
    user=('--user' "${user}")
  fi

  message_alert "$*"
  docker run -it "${envVars[@]}" "${mounts[@]}" "${user[@]}" "${ports[@]}" "${_dImageName}" "$@"
}

function dsave {
  local imageName
  local fileName
  if [[ -z "$1" ]]; then
    dimage "$@"
    imageName="${_dImageName}"
    fileName="${_dService,,}.tgz"
  else
    imageName="$1"
    version=${1##*:}
    fileName="$(basename "${1%%:*}")-${version}.tgz"
  fi

  message_alert "Exporting ${imageName}"
  docker save "$imageName" | gzip > "${fileName}"

  ls -lrt "${fileName}"
}
