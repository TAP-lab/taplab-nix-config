set -e

sudo rm /etc/nixos/configuration.nix

sudo cp * /etc/nixos -r

sudo nixos-rebuild switch

sudo reboot