{ config, pkgs, ... }:

{
    environment.systemPackages = [
        pkgs.libnotify      # For notify-send command
    ];

    # Sets up a systemd service and timer to run the autoupdate script daily
    systemd.services.nixos-update = {
        description = "Periodic NixOS system update with notification";
        serviceConfig = {
        Type = "oneshot";
        # Executes the autoupdate script
        ExecStart = "${pkgs.bash}/bin/bash /home/taplab/nix-config/scripts/autoupdate.sh";
        };
    };

    systemd.timers.nixos-update = {
        description = "Update the system daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
        OnCalendar = "daily";         # Runs the update daily (12:00 AM)
        Persistent = true;            # Runs the job as soon as possible if it was missed
        };
    };
}