{ pkgs, ... }:
let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = [ pkgs.git pkgs.nixos-rebuild ];
    text = ''
      REPO=/root/nix-config
      cd $REPO

      if [ ! -d "$REPO" ]; then
        echo "Error: Git repo does not exist at $REPO"
        exit 1
      fi

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
      nixos-rebuild switch --flake ".#$(hostname)"
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
    # wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${autoUpdateScript}/bin/nixos-auto-update";
    };
  };

  systemd.timers.nixos-auto-update = {
    description = "NixOS Auto Update Timer";
    # wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "1h";
      Persistent = true;
    };
  };

  environment.etc."autoupdate-test".test = ''if this file exists, the auto update script is working correctly'';
}