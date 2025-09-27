set -e

cd /tmp

nix-env -iA nixos.git

git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

sudo rm /etc/nixos/configuration.nix

sudo cp * /etc/nixos -r

sudo nixos-rebuild switch

cd /tmp

rm -rf taplab-nix-config

reboot