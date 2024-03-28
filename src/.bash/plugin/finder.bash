
#====[ fzf ]================================================
export FZF_DEFAULT_OPTS="--height 50% --layout reverse --border --preview 'batcat {}'"

#====[ search ]=============================================
alias ff="find . -type f -not -path \"*/.git/*\" -name "
alias fd="find . -type d -not -path \"*/.git/*\" -name "

function fif {
  skip=()
  if [[ -n $FINDER_EXCLUDE_DIRS ]]; then
    IFS=',' read -ra dirs <<< "$FINDER_EXCLUDE_DIRS"
    for d in "${dirs[@]}"; do
      skip+=(-not -path "*/${d}/*")
    done
  else  
    skip+=(-not -path "*/.git/*");
    skip+=(-not -path "*/.*venv/*");
  fi

  results=$(find . -type f "${skip[@]}" -exec grep "$1" {} +  2> /dev/null)
  for arg in "${@:2}"
  do
    results=$(echo "$results" | grep "$arg")
  done
  echo "${results[*]}"
}
