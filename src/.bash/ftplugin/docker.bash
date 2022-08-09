source "${HOME}/bin/common.sh"

#====[ docker ]=============================================
alias dstop='docker stop $(docker ps -q)'
alias dnostart='docker update --restart=no $(docker ps --all -q)'
alias dclean='docker rmi -f $(docker images -f "dangling=true" -q)'
alias dlogin='ln -s ~/.docker/config.json.keep ~/.docker/config.json'
alias dlogout='rm -f ~/.docker/config.json'

function dbuild {
  registry='harbor.nasiccloud.io/dms/'
  service=$(basename "$(pwd)")
  version='0.0.0'
  context='..'
  progress='auto'
  dfile="$(pwd)/Dockerfile"
  cache=

  if [[ -f VERSION.txt ]];then
    version=$(cat VERSION.txt)
  fi

  for arg in "$@"
  do  
    case "${arg}" in
    --progress=*)
      progress=${arg#*=}
    ;;
    --plain)
      progress='plain'
    ;;
    --cache)
      cache=
    ;;
    --nocache)
      cache='--no-cache'
    ;;
    --registry=*)
      registry=${arg#*=}
    ;;
    --service=*)
      service=${arg#*=}
    ;;
    --version=*)
      version=${arg#*=}
    ;;
    --context=*)
      context=${arg#*=}
    ;;
    esac
  done

  docker build --build-arg PULL_REGISTRY="${registry}" ${cache} --progress "${progress}" --tag "local-dms/${service}:${version}-PRESSEL" --file "${dfile}" "${context}"

  message_alert "Built image: local-dms/${service}:${version}-PRESSEL"
}

function drun {
  registry='harbor.nasiccloud.io/dms/'
  service=$(basename "$(pwd)")
  version='0.0.0'
  context='..'
  progress='auto'
  dfile="$(pwd)/Dockerfile"
  cache=

  if [[ -f VERSION.txt ]];then
    version=$(cat VERSION.txt)
  fi

  declare entry
  if [[ $# -gt 0 ]]; then
    entry="--entrypoint $@"
  fi

  docker run -it ${entry} "local-dms/${service}:${version}-PRESSEL" 
}
