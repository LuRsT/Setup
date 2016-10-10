#!/usr/bin/env bash

DOCKER_CONTAINERS_RUNNING=$(expr "$(docker ps | wc -l)" - 1)
VPN_RUNNING=$(expr "$(ps -ef | grep "sudo openvpn" | wc -l)" - 1)

if [ $VPN_RUNNING == 1 ]; then
    VPN_STRING='#[fg=green]✹#[default]';
else
    VPN_STRING='#[fg=red]✹#[default]';
fi

echo "docker:" $DOCKER_CONTAINERS_RUNNING "VPN:" $VPN_STRING
