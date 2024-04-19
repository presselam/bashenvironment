
#====[ fzf ]================================================
export FZF_DEFAULT_OPTS="--height 50% --layout reverse --border --preview 'batcat {}'"

#====[ search ]=============================================
alias ff="find . -type f -not -path \"*/.git/*\" -name "
alias fd="find . -type d -not -path \"*/.git/*\" -name "

function fif {
  local -a skip

  if [[ -n $FINDER_EXCLUDE_DIRS ]]; then
    IFS=',' read -ra dirs <<< "$FINDER_EXCLUDE_DIRS"
    for d in "${dirs[@]}"; do
      skip+=(-not -path "*/${d}/*")
    done
  else
    skip+=(-not -path "*/.git/*");
    skip+=(-not -path "*/.*venv/*");
    skip+=(-not -path "*/node_modules/*");
  fi

  results=$(find . -type f "${skip[@]}" -exec rg --smart-case "$1" {} +  2> /dev/null)
  for arg in "${@:2}"
  do
    results=$(echo "$results" | rg --smart-case "$arg")
  done
  echo "${results[*]}"
}

function fzg {

  results=$(rg --line-number --no-heading --color=always --smart-case "$1")
  for arg in "${@:2}"
  do
    results=$(echo "$results" | rg --smart-case "$arg")
  done

  echo "${results}" | \
    fzf -d ':' -n 2 --ansi --no-sort --preview-window 'down:+{2}' --preview 'batcat --style=numbers --color=always --highlight-line {2} {1}'  | \
    cut -d ':' -f 1
}
