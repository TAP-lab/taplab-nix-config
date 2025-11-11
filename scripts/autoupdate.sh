source /etc/profile         # Imports the PATH
REPO_URL="https://github.com/TAP-lab/taplab-nix-config.git"   # Sets the repository URL
# Notifies the user that the update process is starting
sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update process starting...'
if [ -d "/home/taplab/nix-config/.git" ]; then      # Checks if the config directory is already present
    BRANCH=$(git rev-parse --abbrev-ref HEAD)       # Gets the current branch
    git pull --rebase origin "$BRANCH"              # Pulls the latest changes from the target branch
    # Copies the new configuration files
    rsync -av --exclude='.git' /home/taplab/nix-config/ /etc/nixos/
    nixos-rebuild switch && SUCCESS=true || SUCCESS=false         # Rebuilds the system
else
    git clone --branch main "$REPO_URL" /home/taplab/nix-config         # Clones the configuration repository
    # Copies the configuration files
    rsync -av --exclude='.git' /home/taplab/nix-config/ /etc/nixos/
    nixos-rebuild switch && SUCCESS=true || SUCCESS=false         # Rebuilds the system
fi
if [ "$SUCCESS" = true ]; then      # Checks if the rebuild was successful
    # Notifies the user that the update process was successful
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update completed successfully!'
else
    # Notifies the user that the update process failed
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update FAILED!'
fi