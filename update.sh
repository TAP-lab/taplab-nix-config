set -e

# Ensure the script is run with sudo privileges for unattended execution
sudo echo

cd /tmp

# Clean up any previous update attempts
rm -rf taplab-nix-config

# Clone the latest configuration
git clone https://github.com/clamlum2/taplab-nix-config.git

cd taplab-nix-config

# Sync the configuration files to /etc/nixos, excluding certain files
sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /etc/nixos/

# Rebuild the NixOS system 
sudo nixos-rebuild switch --profile-name "updated from script $(date '+%Y-%m-%d_%H-%M-%S')"

cd /tmp

# Clean up
rm -rf taplab-nix-config

echo "Update complete, please reboot if the drivers/kernel were updated."