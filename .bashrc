# XDG
export XDG_CONFIG_HOME="${HOME}/.xdg"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source alias
if [ -f ${XDG_CONFIG_HOME}/.alias ]; then
    . ${XDG_CONFIG_HOME}/.alias
fi

# Source extra alias
if [ -f ${HOME}/.alias ]; then
    . ${HOME}/.alias
fi

# Check for an interactive session
[ -z "$PS1" ] && return


PS1='[\u@\e[0;31m\h\e[m \W]\[$(tput setaf 7)\] \j$ '
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#I_#P") "$PWD")'

complete -cf sudo
complete -cf man
complete -cf pacman

# Autocd to a directory when you type it
shopt -s autocd

# Correct for misspelled directory names
shopt -s cdspell
shopt -s dirspell

setterm -blength 0

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
