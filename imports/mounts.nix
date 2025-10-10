{ config, pkgs, ... }:

{
  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas/manuhiri" = {
    device = "//nas/manuhiri";
    fsType = "cifs";
    options = [ "guest" ];
  };

fileSystems."/mnt/nas/Hacklings" = {
    device = "//10.0.0.20/awheawhe/STEaM/Hacklings";
    fsType = "cifs";
    options = [ "guest" ];
  };
}