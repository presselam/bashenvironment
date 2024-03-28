#====[ PYTHON SETTINGS ]====================================
export PYTHONPATH="$HOME/lib/python"

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
    app=$(basename $(pwd))
    name=".${app}-venv"
    if [[ $# == 1 ]]; then
      name=".$1-venv"
    fi

    if [[ -d "${name}" ]];then
      message_alert "${name} already exists"
    else
      python3.11 -m venv "${name}"
    fi
  fi

  pyactivate
}
alias pyv=pyvenv

function pylib {
  local path
  if [[ -n $VIRTUAL_ENV ]]; then
    path=$VIRTUAL_ENV
  elif [[ -f Pipfile ]]; then
    path=$(pipenv --venv)
  else
    mapfile -t venv  < <(find . -maxdepth 3 -type d -name '*venv')
    if [[ ${#venv[@]} == 1 ]]; then
      path=${venv[0]}
    fi
  fi

  message_alert "venv: [$path]"
  pushd "${path}"/lib/*/site-packages/ || return 1
}
alias pyl=pylib

function pyrm () {

  local dir
  if [[ -n $VIRTUAL_ENV ]]; then
    dir=$VIRTUAL_ENV
    deactivate
    rm -rf "${dir}"
    return
  fi

  if [[ -f Pipfile ]]; then
    pipenv --rm
    return
  fi

  mapfile -t venv  < <(find . -maxdepth 3 -type d -name '*venv')

  if [[ ${#venv[@]} -lt 1 ]]; then
    message_error 'Unable to find virtual environment'
    return
  fi

  rm -rf "${venv[0]}"
}
alias pyr=pyrm
