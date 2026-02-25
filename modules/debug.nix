{ config, pkgs, ... }:

{
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  users.users.taplab.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sXIx+I7BCq6T4QfiEWqvh+E1d9+y4CrTijURf5Wsq clamt" ];

  programs.nix-ld.enable = true;

  environment.systemPackages = [ pkgs.libsForQt5.kdbusaddons ];
}
