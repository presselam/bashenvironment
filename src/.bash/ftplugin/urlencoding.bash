
function urlencode {
  length="${#1}"
  i=0
  while [ "$i" -lt "$length" ]; do
    c="${1:$i:1}"
    case $c in
        [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
        *) printf '%%%02X' "'$c" ;;
    esac
    ((i += 1))
  done
}

function urldecode {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}
