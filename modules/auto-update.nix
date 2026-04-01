{ pkgs, ... }:
let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = [ pkgs.git pkgs.nixos-rebuild pkgs.systemd ];
    text = ''
      set -euo pipefail

      REPO=/root/nix-config

      if [ ! -d "$REPO" ]; then
        echo "Error: Git repo does not exist at $REPO"
        git clone https://github.com/tap-lab/taplab-nix-config.git $REPO
      fi

      cd $REPO

      git fetch origin

      LOCAL=$(git rev-parse HEAD)
      REMOTE=$(git rev-parse "@{u}")

      if [ "$LOCAL" = "$REMOTE" ]; then
        echo "Already up to date"
        exit 0
      fi

      cp /etc/nixos/hardware-configuration.nix $REPO/hardware-configuration.nix

      echo "Updating from $LOCAL to $REMOTE"
      git pull --ff-only origin
      systemd-run --no-block --collect --unit=nixos-auto-rebuild nixos-rebuild switch --flake "$REPO#$(cat /etc/hostname)"
      echo "Done"
    '';
  };
in
{
  environment.systemPackages = [ autoUpdateScript ];

  systemd.services.nixos-auto-update = {
    description = "NixOS Auto Update Service";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Delegate = "yes";
      ExecStart = "${autoUpdateScript}/bin/nixos-auto-update";
    };
  };

  systemd.timers.nixos-auto-update = {
    description = "NixOS Auto Update Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };

  environment.etc."autoupdate-test".text = ''if this file exists, the auto update script is working correctly'';
}