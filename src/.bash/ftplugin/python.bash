#====[ PYTHON SETTINGS ]====================================
export PYTHONPATH="$HOME/lib/python"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/anaconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
     . "${HOME}/anaconda3/etc/profile.d/conda.sh"
  else
     export PATH="${HOME}/anaconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

# python virtual environment. my powerline shows it
export VIRTUAL_ENV_DISABLE_PROMPT=1

#====[ PYTHON FUNCTIONS ]===================================
function pyactivate () {
  
  mapfile -t venv  < <(find . -type d -name '*venv')

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
  if [[ $# != 1 ]]; then
    message_error 'Must specify a name'
    return
  fi

  name="$1-venv"

  if [[ -d "${name}" ]];then
    message_alert "${name} already exists"
  else
    python3 -m venv "${name}"
  fi

  pyactivate
}
alias pyv=pyvenv
