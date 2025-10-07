{ config, pkgs, ... }:

{
  systemd.services.nixos-update = {
    description = "Periodic NixOS system update with notification";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /home/taplab/nix-config/imports/autoupdate.sh";
    };
  };

  systemd.timers.nixos-update = {
    description = "Update the system daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}