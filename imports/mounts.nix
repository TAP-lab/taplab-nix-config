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

  fileSystems."/mnt/nas/mema" = {
    device = "//192.168.1.220/mema";
    fsType = "cifs";
    options = [ "credentials=/etc/nixos/secrets/mema" "nofail" "noauto" ];
  };
}