#!/bin/bash

# Hide mouse cursor while typing
unclutter -idle 2 &

# Setup background
setup_background &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

xfce4-clipman &

nm-applet &

dropbox start &
