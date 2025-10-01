set -e

# get disk parameter or default to /dev/sda
DISK=${1:-/dev/sda}

echo "Installing NixOS on disk: $DISK"

# partition the disk
parted -s $DISK -- mklabel msdos

parted -s $DISK -- mkpart primary 1MB -8GB

parted -s $DISK -- set 1 boot on

parted -s $DISK -- mkpart primary linux-swap -8GB 100%

# format the partitions
yes | mkfs.ext4 -L nixos ${DISK}1

mkswap -L swap ${DISK}2

# prevents errors
sleep 1

# mount the partitions
mount /dev/disk/by-label/nixos /mnt

# enable the swap partition
swapon ${DISK}2

# generate the hardware configuration file
nixos-generate-config --root /mnt

cd /tmp

# download the configuration files
git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

# remove the existing configuration file
rm /mnt/etc/nixos/configuration.nix

# copy the new configuration files
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/

# install the os
nixos-install --no-root-passwd

reboot