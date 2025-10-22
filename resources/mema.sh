#!/usr/bin/env bash

sudo mkdir -p /etc/nixos/secrets

URL="http://192.168.1.220:8080/mema"

sudo curl -fsSL "$URL" -o /etc/nixos/secrets/mema

sudo mount -t cifs //192.168.1.220/mema /mnt/nas/mema -o credentials=/etc/nixos/secrets/mema,uid=1000,gid=100,file_mode=0644,dir_mode=0755