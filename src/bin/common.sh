NORMAL="\033[m"        # White
RED_TEXT="\033[31m"    # Red
GREEN_TEXT="\033[32m"  # Green

function message {
  echo
  echo "====> " "$(date)"
  printf "${NORMAL}  %s${NORMAL}\n" "$@"
}

function message_error {
  echo
  echo "====> " "$(date)"
  printf "${RED_TEXT}  %s${NORMAL}\n" "$@"
}

function message_alert {
  echo
  echo "====> " "$(date)"
  printf "${GREEN_TEXT}  %s${NORMAL}\n" "$@"
}

function setupEnvironment {
  message_alert "Setting up Environment"

  echo "" >> "${localFile}"
  echo "# mti-conf-injected" >> "${localFile}"

  if [[ ${#configuration[@]} == 0 ]]; then
    message_error "No configuration set; bad caller"
    exit 9
  fi

  mapfile -t sorted < <(echo "${!configuration[@]}" | tr ' ' '\n' | sort)

  width=1
  for param in "${sorted[@]}"; do
    wide=${#param}
    if [[ ${width} -lt ${wide} ]];then
      width=${wide}
    fi
  done

  for param in "${sorted[@]}"; do
    if grep -qw "${param}" "${localFile}"; then
     printf "%9s: %-${width}s => %s\n" 'Replacing' "${param}" "${configuration[$param]}"
     sed -i "s/export ${param}=.*/export ${param}='${configuration[${param}]//\//\\\/}'/" "${localFile}"
    else
     printf "%-9s: %-${width}s => %s\n" 'Adding' "${param}" "${configuration[$param]}"
     echo "export ${param}='${configuration[$param]}'" >> "${localFile}"
    fi
  done

  message_alert "Checking for Misconfigured Variables"
  grep "\-\-REPLACE\-\-" "${localFile}"
}
