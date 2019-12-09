#!/usr/bin/env bash

DOCKER_CONTAINERS_RUNNING=$(expr "$(docker ps | wc -l)" - 1)
DOCKER_ICON="⊞ "

MEM_FREE=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2/1000000}')

POMODORO_RUNNING=$(ps aux | grep pomodoro | wc -l)
if [ $POMODORO_RUNNING -eq 2 ]
then
    POMO="🕛"
else
    POMO=""
fi

echo -e "$POMO RAM: $MEM_FREE GB $DOCKER_ICON: $DOCKER_CONTAINERS_RUNNING"
