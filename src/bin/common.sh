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

#function myip () {
# ipaddr=$(hostname -I | awk -F' ' '{print $1}')
#  ipaddr=$(grep host.docker.internal /etc/hosts | awk '{ print $1}')
#
#  if [[ -z ${ipaddr} ]]; then
#    for interface in 'eth2' 'eth1' 'eth0' 'wifi0'
#    do
#      echo ${interface}
#      ipaddr=$(ifconfig ${interface} | grep 'inet ' | awk '{print $2}')
#      if [[ -n ${ipaddr} ]]; then
#        break
#      fi
#    done
#  fi
#
#  if [[ -z ${ipaddr} ]]; then
#    message_alert "Unable to determine local ipaddr"
#    exit 1
#  fi
#
#  echo "${ipaddr}"
#}
