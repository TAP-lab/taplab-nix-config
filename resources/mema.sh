#!/usr/bin/env bash

sudo mkdir -p /etc/nixos/secrets

URL="http://192.168.1.220:8080/mema"

sudo curl -fsSL "$URL" -o /etc/nixos/secrets/mema
