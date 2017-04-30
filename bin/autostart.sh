#!/bin/bash

# Hide mouse cursor while typing
unclutter -idle 2 &

# Setup background
setup_background &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

xfce4-clipman &

nm-applet &

xrandr --output eDP-1 --brightness 0.7 &

redshift -l 51.5073:0.12755 &

start-pulseaudio-X11 &

dropbox start &
