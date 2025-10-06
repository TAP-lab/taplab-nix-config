set -e

MY_PUBKEY="local-cache:hCuO1qKsO9DuwvGqG180WyTIXPq6Gv36GWUBeux0CrA="
export NIX_CONF_DIR="/tmp/nix_conf"
mkdir -p "$NIX_CONF_DIR"
cat > "$NIX_CONF_DIR/nix.conf" <<EOF
substituters = http://192.168.1.180:5000 https://cache.nixos.org
trusted-public-keys = $MY_PUBKEY
EOF

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
			echo "Error: Unknown argument: $1" >&2
			exit 1
			;;
	esac
done

echo "Installing NixOS on disk: $DISK"
echo "Using configuration branch: $BRANCH"

parted -s $DISK -- mklabel msdos
parted -s $DISK -- mkpart primary 1MB -8GB
parted -s $DISK -- set 1 boot on
parted -s $DISK -- mkpart primary linux-swap -8GB 100%

yes | mkfs.ext4 -L nixos ${DISK}1
mkswap -L swap ${DISK}2

sleep 1

mount /dev/disk/by-label/nixos /mnt
swapon ${DISK}2

echo "Disks successfully partitioned and formatted."

nixos-generate-config --root /mnt

cd /tmp
echo "Cloning configuration repo using branch: $BRANCH"
git clone --branch "$BRANCH" https://github.com/clamlum2/taplab-nix-config.git
cd taplab-nix-config

rm /mnt/etc/nixos/configuration.nix
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/

nixos-install --no-root-passwd

reboot