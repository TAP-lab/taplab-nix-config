{ config, pkgs, lib, ... }:

let
  updateScriptUrl = "https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh";
  notify = "${pkgs.libnotify}/bin/notify-send";
in
{
  systemd.services.nixos-update = {
    description = "Periodically updates the nix config";
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${notify} 'NixOS Update' 'Update process started!'";
      ExecStart = "${pkgs.bash}/bin/bash -c 'curl -sSfL ${updateScriptUrl} | ${pkgs.bash}/bin/bash' && ${notify} \"NixOS Update\" \"Update completed successfully!\" || ${notify} \"NixOS Update\" \"Update FAILED!\"'";
    };
  };

  systemd.timers.nixos-update = {
    description = "Daily NixOS system update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:0/5:00";
      Persistent = true;
    };
  };
}