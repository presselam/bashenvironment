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
  args=$(getopt -o pnc: --long plain,nocache,context:,verbose -n dbuild -aq -- "$@")

  context='.'
  progress='auto'
  dfile="$(pwd)/Dockerfile"
  cache=""
  verbose=0

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -p | --plain)    progress='plain'; shift   ;;
      -n | --nocache)  cache='yes';      shift   ;;
      -c | --context)  context="$2";     shift 2 ;;
      --verbose)       verbose=1;        shift   ;;
      --) shift; break;;
    esac
  done

  mapfile -d ' ' buildArgs < <(echo -n "$WORKDBUILDARGS")

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
  args=$(getopt -o p:u:m: --long port:,user:,mount: -n drun -aq -- "$@")

  local user
  local -a ports
  local -a mounts

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -u | --user)     user="$2";         shift 2;;
      -p | --port)     ports+=(-p "$2");  shift 2;;
      -m | --mount)    mounts+=(-v "$2"); shift 2;;
      --) shift; break;;
    esac
  done

  if [[ -n "${user}" ]]; then
    user=('--user' "${user}")
  fi

  message_alert "$*"
  docker run -it "${mounts[@]}" "${user[@]}" "${ports[@]}" "${_dImageName}" "$@"
}

function dsave {
  dimage "$@"

    fileName="${_dService,,}.tgz"

    message_alert "Exporting ${_dImageName}"
    docker save "${_dImageName}" | gzip > "${fileName}"

    ls -lrt "${fileName}"
}
