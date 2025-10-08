{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        pkgs.libnotify      # For notify-send command
    ];

    # Sets up a systemd service and timer to run the autoupdate script daily
    systemd.services.nixos-update = {
        description = "Periodic NixOS system update with notification";
        serviceConfig = {
        Type = "oneshot";
        # Executes the autoupdate script
        ExecStart = "${pkgs.bash}/bin/bash /home/taplab/nix-config/imports/autoupdate.sh";
        };
    };

    systemd.timers.nixos-update = {
        description = "Update the system daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
        OnCalendar = "daily";         # Runs the update daily
        Persistent = true;            # Runs the job as soon as possible if it was missed
        };
    };
}