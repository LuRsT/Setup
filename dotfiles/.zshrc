## START ANTIGEN

source $HOME/bin/antigen.zsh

antigen use oh-my-zsh

antigen bundle pip
antigen bundle command-not-found
antigen bundle ssh-agent

antigen bundle andrewferrier/fzf-z
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle lurst/geometry

antigen apply

## END ANTIGEN

alias sway="export XKB_DEFAULT_LAYOUT=gb; export XKB_DEFAULT_OPTIONS=ctrl:nocaps; export XKB_DEFAULT_MODEL=pc101; sway"

# Options for geometry theme
export PROMPT_VIRTUALENV_ENABLED=true
export PROMPT_GEOMETRY_GIT_CONFLICTS=true

source ${HOME}/.commonshellrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if (( $+commands[tag] )); then
    tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
    alias ag=tag
fi

mdviewer () {
    pandoc $* | lynx -stdin
}

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
