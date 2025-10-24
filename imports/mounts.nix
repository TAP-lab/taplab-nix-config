{ config, pkgs, ... }:

{
  # Mounts the manuhiri share
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas/manuhiri" = {
    device = "//nas/manuhiri";
    fsType = "cifs";
    options = [
      "guest"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };

  # Mounts the Hacklings share
  fileSystems."/mnt/nas/Hacklings" = {
    device = "//nas/awheawhe/STEaM/Hacklings";
    fsType = "cifs";
    options = [
      "guest"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };

  # Mounts the mema share with credentials
  fileSystems."/mnt/nas/mema" = {
    device = "//nas/mema";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/secrets/mema"
      "nofail"
      "user"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };
}