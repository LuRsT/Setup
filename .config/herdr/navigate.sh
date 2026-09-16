#!/bin/sh
# Smart pane switching with awareness of Vim/Neovim splits, the herdr side of
# vim-tmux-navigator. Vim, Neovim and fzf get the key so they can move between
# their own splits; any other program hands focus to the neighbouring pane.
#
# Usage: navigate.sh <left|down|up|right> <key>

direction="$1"
key="$2"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="$HERDR_ACTIVE_PANE_ID"

if "$herdr" pane process-info --pane "$pane" \
    | grep -qE '"name":"g?(view|l?n?vim?x?|fzf)(diff)?"'; then
    "$herdr" pane send-keys "$pane" "$key" >/dev/null
else
    "$herdr" pane focus --pane "$pane" --direction "$direction" >/dev/null
fi
