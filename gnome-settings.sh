#!/bin/bash
## Gnome instructions
###  Enable on gnome tweaks, middle click paste

### For resizing windows
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
## To make Super+P launch apps
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

## Set up the workspaces (bindings cover 9, only the first 5 are live)
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 5

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

## Alt+Tab cycles every window individually, not one icon per application,
## so switch-windows takes the binding and switch-applications loses it.
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

## ...and only through windows on the current workspace. app-switcher is
## still worth setting in case switch-applications is ever bound again.
gsettings set org.gnome.shell.window-switcher current-workspace-only true
gsettings set org.gnome.shell.app-switcher current-workspace-only true

## Appearance: stock Gnome theme and icons, so no extra packages to install.
## These are resets rather than sets, so running this on a machine that still
## has the old Arc theme puts it back to the default.
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
## Dark mode and the accent colour are built into Gnome, no theme needed
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface accent-color 'green'
## No animations, and show the battery percentage in the top bar
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface show-battery-percentage true

## UK layout, caps lock as another ctrl, and ctrl+alt+backspace to kill X
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'gb')]"
## ctrl:nocaps, not caps:ctrl_modifier: the latter leaves the keysym as
## Caps_Lock and only attaches a Control action, so apps that read the keysym
## rather than the modifier still see caps lock. ctrl:nocaps replaces the key.
gsettings set org.gnome.desktop.input-sources xkb-options "['terminate:ctrl_alt_bksp', 'ctrl:nocaps']"

## Scroll the way the scrollbar moves, not the way the page moves
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

## Show dotfiles in GTK file dialogs, and don't float directories to the top
gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first false
