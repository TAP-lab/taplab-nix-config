set -e

# partition the disk
parted -s /dev/sda -- mklabel msdos

parted -s /dev/sda -- mkpart primary 1MB -8GB

parted -s /dev/sda -- set 1 boot on

parted -s /dev/sda -- mkpart primary linux-swap -8GB 100%


# format the partitions
yes | mkfs.ext4 -L nixos /dev/sda1

mkswap -L swap /dev/sda2

# prevents errors
sleep 1

# mount the partitions
mount /dev/disk/by-label/nixos /mnt

# enable the swap partition
swapon /dev/sda2

# generate the hardware configuration file
nixos-generate-config --root /mnt

cd /tmp

# download the configuration files
git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

# remove the existing configuration file
rm /mnt/etc/nixos/configuration.nix

# copy the new configuration files
cp * /mnt/etc/nixos -r

# install the os
nixos-install --no-root-passwd

reboot