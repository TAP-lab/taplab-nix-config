{ config, pkgs, ... }:

{
  # For mount.cifs, required unless domain name resolution is not needed.
  # environment.systemPackages = [ pkgs.cifs-utils ];
  # fileSystems."/mnt/nas/manuhiri" = {
  #   device = "//nas/manuhiri";
  #   fsType = "cifs";
  #   options = [ "guest" ];
  # };

  # fileSystems."/mnt/nas/Hacklings" = {
  #   device = "//nas/awheawhe/STEaM/Hacklings";
  #   fsType = "cifs";
  #   options = [ "guest" ];
  # };

  # fileSystems."/mnt/nas/mema" = {
  #   device = "//nas/mema";
  #   fsType = "cifs";
  #   options = let
  #       automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #   in [ "${automount_opts},credentials=/etc/nixos/resources/smb-secrets" ];
  # };
}