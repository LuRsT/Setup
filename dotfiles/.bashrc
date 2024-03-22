# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

source ${HOME}/.commonshellrc

# Check for an interactive session
[ -z "$PS1" ] && return

# Make it visible I'm in bash,
# I don't expect to stay here long
PS1='bash$ '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
