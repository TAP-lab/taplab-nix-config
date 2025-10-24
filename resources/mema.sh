#!/usr/bin/env bash
# not implemented at taplab yet - for my testing

set -e

sudo mkdir -p /etc/nixos/secrets

URL="http://10.0.0.152:8080/mema"

echo "Downloading credentials from $URL..."
if sudo curl -fsSL "$URL" -o /etc/nixos/secrets/mema; then
    echo "Credentials downloaded successfully."
else
    echo "Failed to download credentials." >&2
    exit 1
fi

echo "Mounting CIFS share..."
if sudo mount -t cifs //192.168.1.220/mema /mnt/nas/mema -o credentials=/etc/nixos/secrets/mema,uid=1000,gid=100,file_mode=0644,dir_mode=0755; then
    echo "CIFS share mounted successfully."
else
    echo "Failed to mount CIFS share." >&2
    exit 1
fi