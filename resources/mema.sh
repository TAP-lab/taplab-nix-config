#!/usr/bin/env bash

URL="http://192.168.1.220:8080/wifi"

curl -fsSL "$URL" -o /etc/nixos/secrets/mema
