
alias k='kubectl'

function _kselector {
  unset _kSelectedContianer
  local -A _kContainers
  local -a names

  wide=0
  while IFS=$' ' read -r name state; do
    _kContainers[${name}]=$state 
    if (( wide < ${#name} )); then
      wide=${#name}
    fi
  done < <(kubectl get pods --no-headers)

  mapfile -t sorted_keys < <(echo "${!_kContainers[@]}" | tr ' ' '\n' | sort)

  if [[ -z "$1" ]]; then
    message_alert "Contianers" ''
    idx=0
    for key in "${sorted_keys[@]}"; do
      printf "  %02d -- %-${wide}s (%s)\n" "${idx}" "${key}" "${_kContainers[$key]}"
      ((idx=idx + 1))
    done

    read -rp "  Select an index: " number
  else
    number=$1
  fi

  if [[ "${number}" =~ ^[0-9]+$ ]]; then
    _kSelectedContianer="${sorted_keys[$number]}"
  else
    for key in "${sorted_keys[@]}"; do
      if [[ "${key}" == *${number}* ]]; then
        names+=("$key")
      fi
    done

    if [[ "${#names[@]}" == 1 ]]; then
      svc=${names[0]}
      _kSelectedContianer="${names[0]}"
    else
      echo "Container '${number}' not found; did you mean:"
      for svc in "${names[@]}"; do
        echo "  ${svc}"
      done
    fi
  fi
}

function ke {
  _kselector "$@"
  message_alert "Logging into ${_kSelectedContianer}"

  cmd=(bash)
  if [[ -n "$2" ]]; then
    cmd=("${@:2}")
  fi

  kubectl exec -it "${_kSelectedContianer}" -- "${cmd[@]}"
}

function ker {
  _kselector "$@"
  message_alert "Logging into ${_kSelectedContianer}"

  cmd=(bash)
  if [[ -n "$2" ]]; then
    cmd=("${@:2}")
  fi

  kubectl exec -it --user root "${_kSelectedContianer}" -- "${cmd[@]}"
}

function kl {
  _kselector "$@"
  message_alert "Tailing logs for ${_kSelectedContianer}"
  kubectl logs -f "${_kSelectedContianer}"
}

