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
      ExecStartPre = "${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send 'NixOS Update' 'Update process starting...'";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -sSfL ${updateScriptUrl} | ${pkgs.bash}/bin/bash && ${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send \"NixOS Update\" \"Update completed successfully!\" || ${pkgs.sudo}/bin/sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.libnotify}/bin/notify-send \"NixOS Update\" \"Update FAILED!\"'";
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