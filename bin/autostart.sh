#!/bin/bash

# Hide mouse cursor while typing
unclutter -idle 2 &

# Setup background
feh --bg-scale ~/.xdg/background.jpg &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

xfce4-xclipman &
