declare -gA _work_modes
declare -gA _work_vars
unset WORKPRE

function _work_init {
  pre="${FUNCNAME[2]}"
  if [[ -z "${pre}" ]]; then echo 'No project identified'; return; fi

  # remove any existing vars from another project
  for key in "${!_work_vars[@]}"
  do
    eval "unset ${key}"
    unset _work_vars["${key}"]
  done


  message_alert "Setting Workspace to: $pre"

  complete -F _proj_completer "${pre}"

  #====[ Remove Custom Modes ]================================
  for m in "${!_work_modes[@]}"; do
    unset _work_modes["${m}"]
  done

  wanted=0
  rcFile="${HOME}/.${pre}projrc"
  _work_environment 'WORKPRE' "${pre}"

  #====[ Read Project Config ]================================
  while IFS="" read -r ln; do
    if [[ "${ln}" =~ ^[:space:]*# ]]; then continue;                 fi
    if [[ "${ln::1}" != " " ]];       then wanted=0;                 fi
    if [[ "${ln::5}" == "init:" ]];   then wanted='init' ; continue; fi
    if [[ "${ln::6}" == "modes:" ]];  then wanted='modes'; continue; fi
    if [[ ${wanted} == 0 ]];          then continue;                 fi

    # echo "[${ln}][${wanted}]"
    key=$(echo "${ln%%:*}" | awk '{$1=$1;print}')
    value=$(echo "${ln#*:}" | awk '{$1=$1;print}')
    if [[ ${value::1} == '"' ]]; then value=$(eval echo "${value}"); fi
    if [[ ${value::1} == "'" ]]; then value=$(echo "${value}" | awk '{print substr($0,2,length($0)-2)}'); fi

    # shellcheck disable=SC2034
    if [[ "${wanted}" == 'init' ]]; then _work_environment "${key}" "${value}"; fi
    if [[ "${wanted}" == 'modes' ]]; then _work_modes[${key}]=${value}; fi

  done <"${rcFile}"
}

function _work_environment () {
  local envName=$1
  local envValu=$2

  printf "%s: %-10s => %s\n" 'Adding' "${envName}" "${envValu}"
  export "${envName}"="${envValu}"

  _work_vars[${envName}]="${envValu}"
}

function _work_rcFile () {
  rcFile=$1
  if [[ -z "${rcFile}" ]]; then
    rcFile="${HOME}/.${pre}projrc"
  fi

  $EDITOR "${rcFile}"
}

function _work_config () {
  confScript=$1
  if [[ -z "${confScript}" ]]; then
    confScript="$HOME/bin/$WORKPRE.conf.sh"
  fi

  $EDITOR "${confScript}"
}

function _work_setup_env {
  confScript=$1
  if [[ -z "${confScript}" ]]; then
    confScript="$HOME/bin/$WORKPRE.conf.sh"
  fi

  if ! "${confScript}" "$1"; then
    message_error "Unable to configure this directory [$?]"
    return 1
  fi

  if [[ -f environment.sh ]]; then
    message_alert 'Sourcing environment.sh'
    source environment.sh
  else
    message_error 'Unable to find environment file'
    return 1
  fi
}

function _work_router {

  pre=${FUNCNAME[1]}
  if [[ -z "${pre}" ]]; then echo "Unable to identify work prefix"; return; fi

  declare -A modes
  modes=(
    ['init']='_work_init'     \
    ['conf']='_work_config'   \
    ['env']='_work_setup_env' \
    ['rc']='_work_rcFile'     \
  )

  for m in "${!_work_modes[@]}"; do
    modes["${m}"]="${_work_modes[${m}]}"
  done

  # for tab completion
  if [[ "$#" -eq 0 ]]; then
    echo "${!modes[@]}"
    return
  fi

  declare requested

  for m in "${!modes[@]}"
  do
    for var in "$@"
    do
      # echo "[${var}][${m}]"
      if [[ "${m}" == "${var}"* ]]; then
        requested+=("${m}")
      fi
    done
  done

  if [[ ${#requested[@]} == 1 ]]; then
    mode=${requested[0]}
    cmd=${modes["${mode}"]}
    "${cmd}" "${@:2}"
  else
    message_error "Ambiguous modes: ${requested[*]}"
  fi
}


# calling ${HOME}/bin/mti will cause an infinite loop
#geoModes=$(geo)
#complete -F _geocompleter geo
function _proj_completer {

  if [[ ${#COMP_WORDS[@]} == 2 ]]; then
    mapfile -t matches < <(compgen -W "conf env init ${!_work_modes[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")
    COMPREPLY=( "${matches[@]}" )
  fi

  if [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
    mode="${COMP_WORDS[1]}"
    if [[ "${_work_modes[${mode}]+abc}" ]]; then
        cmd="${_work_modes[${mode}]}"
        mapfile -t startable < <("${cmd}")
        mapfile -t matches < <(compgen -W "${startable[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")
        COMPREPLY=( "${matches[@]}" )
    fi
  fi
  return 0
}
