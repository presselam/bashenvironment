source "${HOME}/bin/common.sh"

#====[ docker ]=============================================
alias dstop='docker stop $(docker ps -q)'
alias dnostart='docker update --restart=no $(docker ps --all -q)'
alias dclean='docker rmi -f $(docker images -f "dangling=true" -q)'
alias dlogin='ln -s ~/.docker/config.json.keep ~/.docker/config.json'
alias dlogout='rm -f ~/.docker/config.json'

function dbuild {
  args=$(getopt -o pns:v:c:r: --long plain,nocache,service:,version:,context:,registry:,verbose -n dbuild -a -- "$@")
  valid=$?
  if [[ "${valid}" != "0" ]]; then
    return 1
  fi

  registry='local-registry'
  service=$(basename "$(pwd)")
  version='0.0.0'
  context='.'
  progress='auto'
  dfile="$(pwd)/Dockerfile"
  cache=""
  verbose=0

  if [[ -f VERSION.txt ]]; then
    version=$(cat VERSION.txt)
  fi

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -p | --plain)    progress='plain';   shift   ;;
      -n | --nocache)  cache='yes';        shift   ;;
      -s | --service)  service="$2";       shift 2 ;;
      -v | --version)  version="$2";       shift 2 ;;
      -c | --context)  context="$2";       shift 2 ;;
      -r | --registry) registry="$2";      shift 2 ;;
      --verbose)       verbose=1;          shift   ;;
      --) shift; break;;
    esac
  done

  image="${registry}/${service}:${version}-PRESSEL"

  cmd=(docker build)
  cmd+=(${WORKDBUILDARGS})
  cmd+=(${cache:+--no-cache})
  cmd+=(--progress "${progress}")
  cmd+=(--tag "${image}")
  cmd+=(--file "${dfile}")
  cmd+=("${context}")

  if [[ ${verbose} == 1 ]]; then
    msg=$(printf '%s ' "${cmd[@]}")
    message "${msg}"
  fi

  "${cmd[@]}"

  message_alert "Built image: ${image}"
}

function drun {
  args=$(getopt -o s:v:r:u: --long service:,version:,registry:,user: -n drun -a -- "$@")
  valid=$?
  if [[ "${valid}" != "0" ]]; then
    return 1
  fi

  local user
  registry='local-registry'
  service=$(basename "$(pwd)")
  version='0.0.0'

  if [[ -f VERSION.txt ]]; then
    version=$(cat VERSION.txt)
  fi

  eval set -- "${args}"
  while :
  do
    case "$1" in
      -s | --service)  service="$2";  shift 2 ;;
      -v | --version)  version="$2";  shift 2 ;;
      -r | --registry) registry="$2"; shift 2 ;;
      -u | --user)     user="$2"; shift 2 ;;
      --) shift; break;;
    esac
  done

  if [[ -n "${user}" ]]; then
    user=('--user' "${user}")
  fi

  image="${registry}/${service}:${version}-PRESSEL"
  message_alert "$@"
  docker run -it "${user[@]}" "${image}" "$@"
}

