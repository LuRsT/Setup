#!/bin/bash

# Hide mouse cursor while typing
unclutter -idle 2 &

redshift -P -O 5000K &

# Setup background
setup_background &

# Setup Caps Lock to Ctrl
setxkbmap gb && sh ~/.xmodmap &

xfce4-clipman &
