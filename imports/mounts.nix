{ config, pkgs, ... }:

{
  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas" = {
    device = "//10.0.0.20/manuhiri";
    fsType = "cifs";
    options = [ "guest" ];
  };
}