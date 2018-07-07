#!/bin/bash

# Hide mouse cursor while typing
unclutter -idle 2 &

redshift -l 51.5073:0.12755 &

# Setup background
setup_background &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

start-pulseaudio-X11 &

dropbox start &
