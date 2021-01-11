#!/bin/bash

file=/tmp/screenshotblur.jpg

if [ -a /tmp/lock.png ]; then
    i3lock -i /tmp/lock.png
else
    scrot "$file"
    convert $file -scale 5% -scale 2000% /tmp/lock.png
    i3lock -i /tmp/lock.png
fi
