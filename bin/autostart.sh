#!/bin/bash
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

ssh-add ~/.ssh/id_ed25519

conky &

