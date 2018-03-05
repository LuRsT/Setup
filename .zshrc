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
