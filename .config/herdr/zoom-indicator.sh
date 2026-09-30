#!/bin/sh
# Prints a magnifying glass while the active pane is zoomed, like the tmux
# status bar does. herdr's built-in zoom entry only offers a fixed ZOOM pill.

herdr="${HERDR_BIN_PATH:-herdr}"
pane="$HERDR_ACTIVE_PANE_ID"

if "$herdr" pane layout --pane "$pane" | grep -q '"zoomed":true'; then
    echo "🔍"
fi
