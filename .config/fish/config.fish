# https://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html
set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

alias g=git
alias v=nvim
alias vi=nvim
alias vim=nvim

export VIMINIT='source $MYVIMRC'

export EDITOR=nvim
export PYTHONDONTWRITEBYTECODE=1
export HISTCONTROL=ignoredups
export HISTFILESIZE=10000 # Record last 10,000 commands
export HISTSIZE=10000 # Record last 10,000 commands per session
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export BROWSER="firefox"
export GOPATH="$HOME/.gospace"

export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin"
