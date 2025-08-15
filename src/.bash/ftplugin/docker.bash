source "${HOME}/bin/common.sh"

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

#====[ docker ]=============================================
alias dstop='docker stop $(docker ps -q)'
alias dnostart='docker update --restart=no $(docker ps --all -q)'
alias dclean='docker rmi -f $(docker images -f "dangling=true" -q)'

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

function _dimage {
  args=$(getopt -o s:v:r: --long service:,version:,registry: -n _dimage -aq -- "$@")

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
  _dimage "$@"
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
  _dimage "$@"
  args=$(getopt -o e:p:u:m:n: --long env:,port:,user:,mount:,network: -n drun -aq -- "$@")

  local user
  local -a ports
  local -a mounts
  local -a envVars
  local -a network

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -u | --user)  user="$2";          shift 2;;
      -p | --port)  ports+=(-p "$2");   shift 2;;
      -m | --mount) mounts+=(-v "$2");  shift 2;;
      -e | --env)   envVars+=(-e "$2"); shift 2;;
      -n | --network)   network+=(--network "$2"); shift 2;;
      --) shift; break;;
    esac
  done

  if [[ -n "${user}" ]]; then
    user=('--user' "${user}")
  fi

  message_alert "$*"
  docker run -it "${network[@]}" "${envVars[@]}" "${mounts[@]}" "${user[@]}" "${ports[@]}" "${_dImageName}" "$@"
}

function dsave {
  local imageName
  local fileName
  if [[ -z "$1" ]]; then
    _dimage "$@"
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


function dps {
  docker ps --format 'table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}' | sort
}

function _dselector {
  unset _dSelectedContianer
  local -A _dContainers
  local -a names

  wide=0
  while IFS=$' ' read -r name image; do
    _dContainers[${name}]=$image
    if (( wide < ${#name} )); then
      wide=${#name}
    fi
  done < <(docker ps --format 'table {{.Names}}\t{{.Image}}' | tail -n +2)

  mapfile -t sorted_keys < <(echo "${!_dContainers[@]}" | tr ' ' '\n' | sort)

  if [[ -z "$1" ]]; then
    message_alert "Contianers" ''
    idx=0
    for key in "${sorted_keys[@]}"; do
      printf "  %02d -- %-${wide}s (%s)\n" "${idx}" "${key}" "${_dContainers[$key]}"
      ((idx=idx + 1))
    done

    read -rp "  Select an index: " number
  else
    number=$1
  fi

  if [[ "${number}" =~ ^[0-9]+$ ]]; then
    _dSelectedContianer="${sorted_keys[$number]}"
  else
    for key in "${sorted_keys[@]}"; do
      if [[ "${key}" == *${number}* ]]; then
        names+=("$key")
      fi
    done

    if [[ "${#names[@]}" == 1 ]]; then
      svc=${names[0]}
      _dSelectedContianer="${names[0]}"
    else
      echo "Container '${number}' not found; did you mean:"
      for svc in "${names[@]}"; do
        echo "  ${svc}"
      done
    fi
  fi
}

function de {
  _dselector "$@"
  message_alert "Logging into ${_dSelectedContianer}"

  cmd=(bash)
  if [[ -n "$2" ]]; then
    cmd=("${@:2}")
  fi

  docker exec -it "${_dSelectedContianer}" "${cmd[@]}"
}

function der {
  _dselector "$@"
  message_alert "Logging into ${_dSelectedContianer}"

  cmd=(bash)
  if [[ -n "$2" ]]; then
    cmd=("${@:2}")
  fi

  docker exec -it --user root "${_dSelectedContianer}" "${cmd[@]}"
}

function dl {
  _dselector "$@"
  message_alert "Tailing logs for ${_dSelectedContianer}"
  docker logs -f "${_dSelectedContianer}"
}

function dimg {
  local -A _dImage
  local wide
  wide=0

  while IFS=$' ' read -r image tag size age; do
    key="${image}:${tag}"

    for arg in "$@"; do
      key=$(echo "${key}" | grep "${arg}")
    done

    if [[ -n "${key}" ]]; then
      _dImage["$key"]=$(printf '%s\t%s' "$size" "$age")
      str="${key#*/}"
      if (( wide < ${#str} )); then
        wide=${#str}
      fi
    fi
  done < <(docker image ls --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' | tail -n +2)

  mapfile -t sorted_keys < <(echo "${!_dImage[@]}" | tr ' ' '\n' | sort)

  current=''
  for key in "${sorted_keys[@]}";
  do
    repo="${key%%/*}"
    image="${key#*/}"
    if [[ "${repo}" != "${current}" ]]; then
      printf -- "- \033[32m%s/\033[m\n" "${repo}"
      current="${repo}"
    fi
    printf "  - %-${wide}s\t%s\n" "${image}" "${_dImage[$key]}"
  done
  # | grep -E "$(IFS='|'; echo "${@[*]}")" | sort)
}

function dscan {
  local imageName

  if [[ -z "$1" ]]; then
    _dimage "$@"
    imageName="${_dImageName}"
  else
    imageName="$1"
  fi

  message_alert "Scanning ${imageName}"
  grype "$imageName" 
}

function dtag {
  local imageName
  local tagName

  if [[ -n "$2" ]]; then
    imageName="$1"
    tagName="$2"
  else  
    _dimage "$@"
    imageName="${_dImageName}"
    tagName="$1"
  fi

  message_alert "Tagging:" "  -- ${imageName}" "  ++ ${tagName}"
  docker tag "$imageName" "$tagName"
}
