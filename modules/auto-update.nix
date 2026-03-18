{ pkgs, self, ... }:

let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = with pkgs; [ git nixos-rebuild ];
    text = ''
        REPO="/etc/nixos"
        REMOTE_URL="https://github.com/tap-lab/taplab-nix-config.git"

        if [ ! -d "$REPO/.git" ]; then
          echo "nixos-auto-update: No repo found, cloning..."
          git clone "$REMOTE_URL" "$REPO" /etc/nixos
        fi

        cd "$REPO"
        git fetch origin

        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse "@{u}")

        if [ "$LOCAL" = "$REMOTE" ]; then
          echo "nixos-auto-update: Already up to date, skipping rebuild."
          exit 0
        fi

        echo "nixos-auto-update: Updates found, pulling and rebuilding..."
        git pull --ff-only origin
        nixos-rebuild switch --flake "$REPO#$(hostname)"
        echo "nixos-auto-update: Done."
    '';
  };

in
{
  environment.systemPackages = [ autoUpdateScript ];

  systemd.services.nixos-auto-update = {
    description = "Auto-update NixOS configuration from git";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${autoUpdateScript}/bin/nixos-auto-update";
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
    serviceConfig.Environment = [
      "GIT_CONFIG_COUNT=1"
      "GIT_CONFIG_KEY_0=safe.directory"
      "GIT_CONFIG_VALUE_0=/home/taplab/nix-config"
    ];
  };

  systemd.timers.nixos-auto-update = {
    # wantedBy = [ "timers.target" ];
    timerConfig.OnUnitActiveSec = "1m";
    timerConfig.Persistent = true;
  };

  environment.etc."autoupdate_test".text = ''if this file exists, the auto-update script is running'';
}