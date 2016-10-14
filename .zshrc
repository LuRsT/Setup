## START ANTIGEN

source $HOME/bin/antigen.zsh

antigen use oh-my-zsh

antigen bundle git
antigen bundle pip
antigen bundle command-not-found
antigen bundle ssh-agent

antigen bundle andrewferrier/fzf-z
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle lurst/geometry

antigen apply

## END ANTIGEN

# Options for geometry theme
export PROMPT_VIRTUALENV_ENABLED=true
export PROMPT_GEOMETRY_GIT_CONFLICTS=true
export PROMPT_GEOMETRY_COLORIZE_SYMBOL=true
export PROMPT_GEOMETRY_COLORIZE_ROOT=true


# Change XDG dir
export XDG_CONFIG_HOME="${HOME}/.xdg"

# Source alias
if [ -f ${XDG_CONFIG_HOME}/.alias ]; then
    source ${XDG_CONFIG_HOME}/.alias
fi

# Source extra alias
if [ -f ${XDG_CONFIG_HOME}/.alias_extra ]; then
    source ${XDG_CONFIG_HOME}/.alias_extra
fi

export WORKON_HOME=$HOME/.virtualenvs
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# for tmux: export 256color
[ -n "$TMUX" ] && export TERM=screen-256color

man() {
    env \
        LESS_TERMCAP_md=$'\e[1;36m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[1;40;92m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;32m' \
        man "$@"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
