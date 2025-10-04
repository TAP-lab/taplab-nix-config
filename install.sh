set -e

# takes the trailing argument after the script as what disk to install to.
# this defaults to /dev/sda and should be correct for all laptops with only one disk in them
# if unsure check the disks by running "lsblk" and look for the disk you wish to use
DISK=${1:-/dev/sda}

echo "Installing NixOS on disk: $DISK"

# this set of commands partitions the selected disk
# makes a msdos partition table for BIOS boot support (these laptops won't work with uefi, not sure why)
parted -s $DISK -- mklabel msdos

# patitions the disk with the necessary boot, main, and swap partitions
parted -s $DISK -- mkpart primary 1MB -8GB
parted -s $DISK -- set 1 boot on
parted -s $DISK -- mkpart primary linux-swap -8GB 100%

# formats the main partition to ext4
yes | mkfs.ext4 -L nixos ${DISK}1

# enables the sawp partition
mkswap -L swap ${DISK}2

# prevents mount command from running before the formatting is complete
sleep 1

# mounts the mian partition so that nixos can be isntalled to it
mount /dev/disk/by-label/nixos /mnt

# enables the swap partition in case it is needed
swapon ${DISK}2

# generates the laptop-specific hardware configuration file
nixos-generate-config --root /mnt

# changes to working in the temp directory
cd /tmp

# downloads the configuration files from github
git clone https://github.com/clamlum2/taplab-nix-config.git
cd taplab-nix-config

# removes the automatically generated configuration file
rm /mnt/etc/nixos/configuration.nix

# copies the configuration files to the new system
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/

# installs the os, skipping the root password to allow for unattened installation
nixos-install --no-root-passwd

# automatically reboots to the newly installed os
reboot

# NEED TO FIGURE OUT LOCAL CACHING