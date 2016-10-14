# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

source ${HOME}/.commonshellrc

# Check for an interactive session
[ -z "$PS1" ] && return

PS1='[\u@\e[0;31m\h\e[m \W]\[$(tput setaf 7)\] \j$ '
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#I_#P") "$PWD")'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
