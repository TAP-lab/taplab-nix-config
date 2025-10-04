set -e

BRANCH="main"
DISK="/dev/sda"

while [[ $# -gt 0 ]]; do
	case $1 in
		--branch)
			BRANCH="$2"
			shift 2
			;;
		--disk)
			DISK="$2"
			shift 2
			;;
		*)
			shift
			;;
	esac
done

echo "Installing NixOS on disk: $DISK"

parted -s $DISK -- mklabel msdos
parted -s $DISK -- mkpart primary 1MB -8GB
parted -s $DISK -- set 1 boot on
parted -s $DISK -- mkpart primary linux-swap -8GB 100%

yes | mkfs.ext4 -L nixos ${DISK}1
mkswap -L swap ${DISK}2

sleep 1

mount /dev/disk/by-label/nixos /mnt
swapon ${DISK}2

nixos-generate-config --root /mnt

cd /tmp
echo "Cloning configuration repo using branch: $BRANCH"
git clone --branch "$BRANCH" https://github.com/clamlum2/taplab-nix-config.git
cd taplab-nix-config

rm /mnt/etc/nixos/configuration.nix
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/

nixos-install --no-root-passwd

reboot