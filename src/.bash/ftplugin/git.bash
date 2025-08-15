alias guntracked='git ls-files --others --exclude-standard'

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
        py)    black "${filename}" ;;
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
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ -z "${branch}" ]]; then
    return
  fi

  branch=$(basename "${branch}")

  [[ ${branch^^} =~ (^[[:alpha:]]+-[[:digit:]]+) ]]
  ticket="${BASH_REMATCH[1]}"

  if [[ -z "${ticket}" ]]; then
    echo "Unable to determine ticket";
    echo "git commit -m \"XXXX-YYYY -- $1\""
    return
  fi

  git commit -m "${ticket^^} -- $*"
}

function gclean {
  git fetch -p
  branch=$(git symbolic-ref refs/remotes/origin/HEAD)
  branch=$(basename "${branch}")
  git checkout "${branch}"
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}

function gfresh {
  git fetch -p
  git checkout .
  git switch main
  git pull
  git switch development
  git pull
}
