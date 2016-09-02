## ANTIGEN CONFIG
source $HOME/bin/antigen.zsh

# Load the oh-my-zsh's library.
antigen-use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen-bundle git
antigen-bundle pip
antigen-bundle lein
antigen-bundle command-not-found

# Syntax highlighting bundle.
antigen-bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen-theme gallois

# Tell antigen that you're done.
antigen-apply

## END ANTIGEN

# XDG
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
