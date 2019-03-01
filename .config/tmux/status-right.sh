#!/usr/bin/env bash

DOCKER_CONTAINERS_RUNNING=$(expr "$(docker ps | wc -l)" - 1)
VPN_RUNNING=$(expr "$(ps -ef | grep "sudo openvpn" | wc -l)" - 1)

if [ $VPN_RUNNING == 1 ]; then
    VPN_STRING='#[fg=green]✹#[default]';
else
    VPN_STRING='#[fg=red]✹#[default]';
fi

DOCKER_ICON="\uf21a"

MEM_FREE=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2/1000000}')

echo -e "$MEM_FREE GB $DOCKER_ICON : $DOCKER_CONTAINERS_RUNNING VPN: $VPN_STRING"
