set -e
 
cd /tmp

git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /etc/nixos/

sudo nixos-rebuild switch --profile-name "updated from script"

cd /tmp

rm -rf taplab-nix-config

echo "Update complete, please reboot if the drivers/kernel were updated."