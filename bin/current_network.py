#!/usr/bin/python

import os

def main():
    output = os.popen("netctl list").read().split("\n")
    for line in output:
        if line.startswith("*"):
            active_network = line[2:]

    assert active_network

    output = os.popen(f"netctl status {active_network}").read().split("\n")
    for line in output:
        if "Status" in line and "online" in line:
            return f"{active_network}"

print(main())
