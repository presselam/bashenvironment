declare -gA _arbeiter_modes
declare -gA _arbeiter_vars
unset WORKPRE

function _arbeiter_init () {
  pre="${FUNCNAME[2]}"
  if [[ -z "${pre}" ]]; then echo 'No project identified'; return; fi

  # remove any existing vars from another project
  for key in "${!_arbeiter_vars[@]}"
  do
    eval "unset ${key}"
    unset _arbeiter_vars["${key}"]
  done


  message_alert "Setting Workspace to: $pre"

  complete -F _arbeiter_proj_completer "${pre}"

  #====[ Remove Custom Modes ]================================
  for m in "${!_arbeiter_modes[@]}"; do
    unset _arbeiter_modes["${m}"]
  done

  wanted=0
  rcFile="${HOME}/.${pre}projrc"

  local -A initVars
  initVars['WORKPRE']="${pre}"

  #====[ Read Project Config ]================================
  if [[ -f "${rcFile}" ]]; then
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
      if [[ "${wanted}" == 'init' ]]; then initVars["${key}"]="${value}"; fi
      if [[ "${wanted}" == 'modes' ]]; then _arbeiter_modes[${key}]=${value}; fi

    done <"${rcFile}"
  fi

  _arbeiter_environment initVars # 2>&1 | cowsay -n -f happy-whale
}

function _arbeiter_environment () {
  local -n envvars=$1

  local width=0
  for var in "${!envvars[@]}"; do
    if [[ ${width} -lt ${#var} ]]; then
      width="${#var}"
    fi
  done

  format="Adding: %-${width}s => %s\n"
  for var in "${!envvars[@]}"; do
    # shellcheck disable=SC2059
    printf "${format}" "${var}" "${envvars[${var}]}"
    export "${var}"="${envvars[${var}]}"
    _arbeiter_vars[${var}]="${envvars[${var}]}"
  done

}

function _arbeiter_rcFile () {
  rcFile=$1
  if [[ -z "${rcFile}" ]]; then
    rcFile="${HOME}/.${pre}projrc"
  fi

  $EDITOR "${rcFile}"
}

function _arbeiter_config () {
  confScript=$1
  if [[ -z "${confScript}" ]]; then
    confScript="$HOME/bin/$WORKPRE.conf.sh"
  fi

  cwd=$(pwd)
  local forSearch
  local -a buffer
  mapfile -d ';' -t buffer < <(${confScript} --list)
  for key in "${buffer[@]}"; do
    if [[ "${key}" != $'\n' ]]; then
      if [[ "${cwd}" == *"${key%%=*}" ]];then
        forSearch="${key#*=}"
      fi
    fi
  done

  if [[ -n "${forSearch}" ]]; then
    $EDITOR -c "silent! /${forSearch}" "${confScript}"
  else
    $EDITOR "${confScript}"
  fi
}

function _arbeiter_setup_env () {
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

function _arbeiter_router () {

  pre=${FUNCNAME[1]}
  if [[ -z "${pre}" ]]; then echo "Unable to identify work prefix"; return; fi

  declare -A modes
  modes=(
    ['init']='_arbeiter_init'     \
    ['conf']='_arbeiter_config'   \
    ['env']='_arbeiter_setup_env' \
    ['rc']='_arbeiter_rcFile'     \
  )

  for m in "${!_arbeiter_modes[@]}"; do
    modes["${m}"]="${_arbeiter_modes[${m}]}"
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
function _arbeiter_proj_completer () {

  if [[ ${#COMP_WORDS[@]} == 2 ]]; then
    mapfile -t matches < <(compgen -W "conf env init ${!_arbeiter_modes[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")
    COMPREPLY=( "${matches[@]}" )
  fi

  if [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
    mode="${COMP_WORDS[1]}"
    if [[ "${_arbeiter_modes[${mode}]+abc}" ]]; then
        cmd="${_arbeiter_modes[${mode}]}"
        mapfile -t startable < <("${cmd}")
        mapfile -t matches < <(compgen -W "${startable[*]}" -- "${COMP_WORDS[$COMP_CWORD]}")
        COMPREPLY=( "${matches[@]}" )
    fi
  fi
  return 0
}

declare _arbeiter_cwd
export _arbeiter_cwd

complete -F _arbeiter_work_completer work
complete -F _arbeiter_cert_completer cert

function _arbeiter_complete () {
  dir=$1
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

function _arbeiter_work_completer () { _arbeiter_complete "$WORKDIR"; }
function _arbeiter_cert_completer () { _arbeiter_complete "$CERTDIR"; }

function _arbeiter_changer () {
  dir=$1
  for arg in "${@:2}"
  do
    dir=${dir}/${arg}
  done

  if [ -d "${dir}" ]; then
    pushd "${dir}" || return
    _arbeiter_cwd="${dir}"
  fi
}

#====[ Public Functions ]===================================
function work () { _arbeiter_changer "$WORKDIR" "$@"; }
function cert () { _arbeiter_changer "$CERTDIR" "$@"; }

function mm  () {
  deep="${#DIRSTACK[@]}"
  if [ "${deep}" -gt 1 ]; then
    popd || return
  fi
}

alias cdw="cd \${_arbeiter_cwd}"
