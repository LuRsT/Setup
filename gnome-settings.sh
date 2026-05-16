#!/bin/bash
## Gnome instructions
###  Enable on gnome tweaks, middle click paste

### For resizing windows
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`
## To make Super+P launch apps
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>p']"

## Set quick display switch to Super M
gsettings set org.gnome.mutter.keybindings switch-monitor "['<Super>m']"
## Set message tray to Super V (It'd be overriden by the above)
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"

## Set shortcut for terminal (Super + Enter)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Alacritty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'alacritty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>Return'

## Set shortcut for file manager (Super + E)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Files'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'

## Set shortcut to close window:
gsettings set org.gnome.desktop.wm.keybindings close "['<Super><Shift>c', '<Alt>F4']"

## Super+F fullscreen
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

## Lock screen with Super+Shift+x
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super><Shift>x', '<Super>l']"

## Set up the 9 workspaces
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 9

for i in $(seq 1 9); do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done

## Set the Super+shift to move windows
for i in $(seq 1 9); do
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done

## Clear other shortcuts that may interfere
for i in $(seq 1 9); do
  gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done
