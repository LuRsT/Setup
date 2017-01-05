#!/bin/bash

if [ -a /tmp/screenshotblur.png ]; then
    i3lock -i /tmp/screenshotblur.png
else
    scrot /tmp/screen_locked.png
    convert /tmp/screen_locked.png -blur 0x5 /tmp/screenshotblur.png
    i3lock -i /tmp/screenshotblur.png
fi
