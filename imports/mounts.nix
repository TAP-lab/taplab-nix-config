{ config, pkgs, ... }:

{
    fileSystems."/mnt/nas" = {
        device = "//nas";
        fsType = "cifs";
    }
}