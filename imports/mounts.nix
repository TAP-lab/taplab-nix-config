{ config, pkgs, ... }:

{
  # Mounts the nas drive
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas/manuhiri" = {
    device = "//nas/manuhiri";
    fsType = "cifs";
    options = [ "nofail" "noauto" "guest" ];
  };

  # Mounts the Hacklings share
  fileSystems."/mnt/nas/Hacklings" = {
    device = "//nas/awheawhe/STEaM/Hacklings";
    fsType = "cifs";
    options = [ "nofail" "noauto" "guest" ];
  };

  # Mounts the mema share with automount options (disabled for now until credentials system is in place)
  # fileSystems."/mnt/nas/mema" = {
  #   device = "//nas/mema";
  #   fsType = "cifs";
  #   options = let
  #       automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #   in [ "${automount_opts},credentials=/etc/nixos/resources/smb-secrets" ];
  # };

  fileSystems."/mnt/test" = {
    device = "//192.168.1.220/media";
    fsType = "cifs";
     options = let
         automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
     in [ "${automount_opts},credentials=/etc/nixos/code/test-login" ];
  };
}