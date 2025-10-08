#!/usr/bin/env bash

set -e      # Sets the script to exit on error
set -e

CACHE_SERVER="http://192.168.1.182:5000"
MY_PUBKEY="local-cache:lF8a6CjzBqT9J38ERYQIUcaEn/Gb5TQ/nuwq9KjTLIA="
export NIX_CONF_DIR="/tmp/nix_conf"
mkdir -p "$NIX_CONF_DIR"
cat > "$NIX_CONF_DIR/nix.conf" <<EOF
substituters = $CACHE_SERVER
trusted-public-keys = $MY_PUBKEY
EOF

BRANCH="main"           # Sets the default branch to clone
DISK="/dev/sda"         # Sets the default disk to install to

while [[ $# -gt 0 ]]; do        # Parses the command line arguments
	case $1 in
		--branch)
			BRANCH="$2"         # Sets the branch to use
			shift 2
			;;
		--disk)
			DISK="$2"           # Sets the disk to install to
			shift 2
			;;
		*)
			echo "Error: Unknown argument: $1" >&2      # Prints an error message for unknown arguments
			exit 1
			;;
	esac
done

echo "Installing NixOS on disk: $DISK"
echo "Using configuration branch: $BRANCH"

parted -s $DISK -- mklabel msdos                            # Creates a new partition table
parted -s $DISK -- mkpart primary 1MB -8GB                  # Creates a new partition for NixOS
parted -s $DISK -- set 1 boot on                            # Sets the boot flag on the first partition
parted -s $DISK -- mkpart primary linux-swap -8GB 100%      # Creates a swap partition

yes | mkfs.ext4 -L nixos ${DISK}1       # Formats the first partition as ext4 and labels it "nixos"
mkswap -L swap ${DISK}2                 # Formats the second partition as swap and labels it "swap"

sleep 1         # Waits for a second to ensure that the previous operations have completed

mount /dev/disk/by-label/nixos /mnt         # Mounts the nixos partition to /mnt
swapon ${DISK}2                             # Enables the swap partition

echo "Disks successfully partitioned and formatted."

nixos-generate-config --root /mnt       # Generates the NixOS configuration files

cd /tmp                                                                             # Changes to the /tmp directory
echo "Cloning configuration repo using branch: $BRANCH"
git clone --branch "$BRANCH" https://github.com/clamlum2/taplab-nix-config.git      # Clones the configuration repository
cd taplab-nix-config                                                                # Changes to the cloned repository directory

rm /mnt/etc/nixos/configuration.nix                                                                                     # Removes the existing configuration file
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/         # Copies the configuration files to /mnt/etc/nixos

nixos-install --no-root-passwd      # Installs NixOS without setting a root password to allow for unattended installation

reboot      # Reboots the system