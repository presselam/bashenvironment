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
