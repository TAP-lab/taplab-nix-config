#!/usr/bin/env bash

set -e

# Ensure the secrets directory exists
sudo mkdir -p /etc/nixos/secrets

SERVER="http://<server ip/name>:8080"

# Downloads the mema credentials
echo "Downloading credentials from $SERVER..."
if sudo curl -fsSL "$SERVER/mema" -o /etc/nixos/secrets/mema; then
    echo "Credentials downloaded successfully."
else
    echo "Failed to download credentials." >&2
    exit 1
fi

# Makes the credentials file readable only by root
sudo chmod 600 /etc/nixos/secrets/mema

# Mounts the share on the fly (usually returns an error but still works)
echo "Mounting CIFS share..."
echo "This returns an error but still works, just check the file explorer to confirm."
echo
if sudo mount -t cifs //nas/mema /mnt/nas/mema -o credentials=/etc/nixos/secrets/mema,uid=1000,gid=100,file_mode=0644,dir_mode=0755; then
    echo "CIFS share mounted successfully."
else
    echo "Failed to mount CIFS share." >&2
    exit 1
fi