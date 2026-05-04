#!/bin/bash
# Lock the screen (via i3lock) using a fresh blurred screenshot.

screenshot=/tmp/screenshotblur.jpg
lock=/tmp/lock.png

scrot "$screenshot"
convert "$screenshot" -scale 5% -scale 2000% "$lock"
i3lock -i "$lock"
