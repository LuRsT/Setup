#!/usr/bin/python

import os

def main():
    output = os.popen("netctl list").read().split("\n")
    active_networks = []
    for line in output:
        if line.startswith("*"):
            active_networks.append(line[2:])

    if len(active_networks) > 1:
        return " + ".join(active_networks)
    else:
        return active_networks[0]

print(main())
