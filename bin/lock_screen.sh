#!/bin/bash

locked=/tmp/screen_locked.jpg
file=/tmp/screenshotblur.jpg

function datamosh() {
    fileSize=$(wc -c < "$file")
    headerSize=1000
    skip=$(shuf -i "$headerSize"-"$fileSize" -n 1)
    count=$(shuf -i 1-10 -n 1)
    for i in $(seq 1 $count);
        do byteStr=$byteStr'\x'$(shuf -i 0-255 -n 1);
    done;
    printf $byteStr | dd of="$file" bs=1 seek=$skip count=$count conv=notrunc >/dev/null 2>&1
}

if [ -a /tmp/lock.png ]; then
    i3lock -i /tmp/lock.png
else
    scrot "$locked"
    convert "$locked" -blur 0x5 "$file"
    datamosh "$file"
    datamosh "$file"
    datamosh "$file"
    datamosh "$file"
    convert "$file" /tmp/lock.png
    i3lock -i /tmp/lock.png
fi
