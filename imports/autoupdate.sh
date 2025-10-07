${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send 'NixOS Update' 'Update process starting...'
if [ -d "/home/taplab/nix-config/.git" ]; then
    BRANCH=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD)
    ${pkgs.git}/bin/git pull --rebase origin "$BRANCH"
    ${pkgs.rsync}/bin/rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' /home/taplab/nix-config/ /etc/nixos/
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false
else
    ${pkgs.git}/bin/git clone --branch main "$REPO_URL" /home/taplab/nix-config
    ${pkgs.rsync}/bin/rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' /home/taplab/nix-config/ /etc/nixos/
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false
fi
if [ "$SUCCESS" = true ]; then
    ${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send 'NixOS Update' 'Update completed successfully!'
else
    ${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send 'NixOS Update' 'Update FAILED!'