
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
