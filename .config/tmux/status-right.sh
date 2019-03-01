#!/usr/bin/env bash

DOCKER_CONTAINERS_RUNNING=$(expr "$(docker ps | wc -l)" - 1)

DOCKER_ICON="\uf21a"

MEM_FREE=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2/1000000}')

echo -e "$MEM_FREE GB $DOCKER_ICON : $DOCKER_CONTAINERS_RUNNING"
