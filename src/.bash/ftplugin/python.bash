#====[ PYTHON SETTINGS ]====================================
export PYTHONPATH="$HOME/lib/python"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$("${HOME}/anaconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
#rc=$?
#if [ "${rc}" -eq 0 ]; then
#  eval "$__conda_setup"
#else
#  if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
#     . "${HOME}/anaconda3/etc/profile.d/conda.sh"
#  else
#     export PATH="${HOME}/anaconda3/bin:$PATH"
#  fi
#fi
#unset __conda_setup
# <<< conda initialize <<<

# python virtual environment. my powerline shows it
export VIRTUAL_ENV_DISABLE_PROMPT=1

#====[ PYTHON FUNCTIONS ]===================================
function pyactivate () {

  if [[ -f Pipfile ]]; then
    pe=$(pipenv --venv)
    if [[ -n "${pe}" ]];then
      source "${pe}/bin/activate"
      return
    fi
  fi
  
  mapfile -t venv  < <(find . -maxdepth 3 -type d -name '*venv')

  if [[ ${#venv[@]} -lt 1 ]]; then
    message_error 'Unable to find virtual environment'
    return
  fi

  if [[ ${#venv[@]} -gt 1 ]]; then
    message_alert 'Found multiple virtual environments:' "${venv[@]}"
    return
  fi

  source "${venv[0]}/bin/activate";
}
alias pya=pyactivate
alias pyd=deactivate

function pyvenv () {

  if [[ -f Pipfile ]]; then
    pe=$(pipenv --venv 2> /dev/null)
    if [[ -n "$pe" ]];then
      message "$(basename "${pe}")  already exists"
      return
    fi

    message 'Found Pipfile; using pipenv'
    pipenv install --dev
    return
  else
    name='.venv'
    if [[ $# == 1 ]]; then
      name=".$1-venv"
    fi

    if [[ -d "${name}" ]];then
      message_alert "${name} already exists"
    else
      python3 -m venv "${name}"
    fi
  fi

  pyactivate
}
alias pyv=pyvenv
alias pylib='pushd $VIRTUAL_ENV/lib/*/site-packages/'

function pyrm () {

  if [[ -z $VIRTUAL_ENV ]]; then
    message_alert 'Not in a virtual environment'
    return
  fi

  dir=$VIRTUAL_ENV
  deactivate

  if [[ -n $PIPENV_ACTIVE ]]; then
    pipenv --rm
  else
    rm -rf "${dir}"
  fi
}
alias pyr=pyrm
