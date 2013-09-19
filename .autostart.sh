feh --bg-tile $HOME/.xdg/background.png &

# Remove beep
xset b 0 440 10 &

# Set backlight
xbacklight -set 60 &

redshift -l 38:-9 &
unclutter &
nm-applet &
~/.dropbox-dist/dropboxd &
DISPLAY='' wuala ^


#xmodmap /home/lurst/.Xmodmap
