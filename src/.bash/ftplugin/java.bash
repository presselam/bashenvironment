
function pom () {
  local path
  path=$(pwd)
  local pomFile
  while [[ "${path}" != '/' ]]; do
    if [[ -f "${path}/pom.xml" ]]; then
      pomFile="${path}/pom.xml"
      break
    fi
    path=$(dirname "${path}")
  done

  if [[ -n "${pomFile}" ]]; then
    ${EDITOR} "${path}/pom.xml"
  else
    message_alert "Unable to find a pom"
  fi  
}
