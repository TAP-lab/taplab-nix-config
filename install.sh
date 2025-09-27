set -e

parted -s /dev/sda -- mklabel msdos

parted -s /dev/sda -- mkpart primary 1MB -8GB

parted -s /dev/sda -- set 1 boot on

parted -s /dev/sda -- mkpart primary linux-swap -8GB 100%

yes | mkfs.ext4 -L nixos /dev/sda1

mkswap -L swap /dev/sda2

sleep 1

mount /dev/disk/by-label/nixos /mnt

swapon /dev/sda2

nixos-generate-config --root /mnt

cd /tmp

nix-env -iA nixos.git

git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

rm /mnt/etc/nixos/configuration.nix

cp * /mnt/etc/nixos -r

nixos-install --no-root-passwd

reboot