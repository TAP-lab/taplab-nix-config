source /etc/profile
sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update process starting...'
if [ -d "/home/taplab/nix-config/.git" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git pull --rebase origin "$BRANCH"
    rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' /home/taplab/nix-config/ /etc/nixos/
    nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false
else
    git clone --branch main "$REPO_URL" /home/taplab/nix-config
    rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' /home/taplab/nix-config/ /etc/nixos/
    nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false
fi
if [ "$SUCCESS" = true ]; then
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update completed successfully!'
else
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update FAILED!'