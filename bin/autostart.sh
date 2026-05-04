#!/bin/bash
# Openbox startup: launches desktop daemons (background, clipboard, notifications, etc.)

# Hide mouse cursor while typing
unclutter -idle 2 &

redshift -O 5000 &

# Setup background
setup_background &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

xfce4-clipman &

solaar &

dunst -conf ~/.config/.dunstrc &

conky &
