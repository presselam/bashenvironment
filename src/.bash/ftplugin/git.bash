
# format with clang-format before adding to git
validFiletypes="c|h|cpp|hpp|js|pl|pm|py"
function gadd {
  cur=0
  argArray=( "$@" )
  while [[ $cur -lt $# ]]; do
    if [[ ${argArray[$cur]} =~ \.($validFiletypes)$ ]]; then
      filename=${argArray[$cur]}
      case ${filename##*.} in
        p[lm]) perltidy -b -nst "$filename" ;;
        py)    autopep8 -a -i "${filename}" ;;
        *)     clang-format -i -style=file "${argArray[$cur]}" ;;
      esac
    else
      echo "No formatter specified: ${argArray[$cur]}"
    fi

    git add -v "${argArray[$cur]}"
    cur=$((cur + 1))
  done
}

function gcommit {
  branch=$(git describe --contains --all HEAD)
  if [[ -z "${branch}" ]]; then
    return
  fi

  [[ ${branch^^} =~ (^[[:alpha:]]+-[[:digit:]]+) ]]
  ticket="${BASH_REMATCH[1]}"

  git commit -m "${ticket^^} -- $1"
}

function term_git_title {

  if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
    if git diff --quiet 2> /dev/null; then
      printf '\ue0a0 %s\n ' "${branch}"
    else
      printf '\ue0a0 %s \u26A1\n ' "${branch}"
    fi
  fi
}
