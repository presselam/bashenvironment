
function pom () {
  local path
  path=$(pwd)
  local -a pomFile
  while [[ "${path}" != '/' ]]; do
    if [[ -f "${path}/pom.xml" ]]; then
      pomFile+=("${path}/pom.xml")
    fi
    path=$(dirname "${path}")
  done

  selected=0
  if [[ ${#pomFile[@]} -gt 1 ]]; then
    message_alert "Found ${#pomFile[@]} pomfiles"
    idx=0
    for pom in "${pomFile[@]}";
    do
      echo "  [${idx}] - $pom"
      idx=$((idx + 1))
    done
    echo "Select pomfile: "
    read -r selected
  fi

  file=${pomFile[${selected}]}

  if [[ -n "${file}" ]]; then
    "${EDITOR}" "${file}"
  else
    message_alert "Unable to find a pom"
  fi  
}
