{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas.taplab.nz/manuhiri" = {
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

  fileSystems."/mnt/nas.taplab.nz/Hacklings" = {
    device = "//nas/awheawhe/Hacklings";
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

  fileSystems."/mnt/nas.taplab.nz/Inventors-Guild" = {
    device = "//nas/awheawhe/Inventors Guild";
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

  fileSystems."/mnt/nas/mema" = {
    device = "//nas.taplab.nz/mema";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/secrets/mema"
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
}