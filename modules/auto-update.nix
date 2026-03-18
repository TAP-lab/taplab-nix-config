{ pkgs, self, ... }:

let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = with pkgs; [ git nixos-rebuild ];
    text = ''
      cd "/home/taplab/nix-config"

      git fetch origin

      LOCAL=$(git -c safe.directory="$REPO" rev-parse HEAD)
      REMOTE=$(git -c safe.directory="$REPO" rev-parse "@{u}")

      if [ "$LOCAL" = "$REMOTE" ]; then
        echo "nixos-auto-update: Already up to date, skipping rebuild."
        exit 0
      fi

      echo "nixos-auto-update: Updates found, pulling and rebuilding..."
      git pull --ff-only origin
      nixos-rebuild switch --flake ".#$(hostname)"
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
  };

  systemd.timers.nixos-auto-update = {
    # wantedBy = [ "timers.target" ];
    timerConfig.OnUnitActiveSec = "1h";
    timerConfig.Persistent = true;
  };
}