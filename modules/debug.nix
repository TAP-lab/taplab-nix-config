{ config, pkgs, ... }:

{
  # Services to allow VM integration.
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # My SSH public key for passwordless login.
  users.users.taplab.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sXIx+I7BCq6T4QfiEWqvh+E1d9+y4CrTijURf5Wsq clamt" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKo8ils310ISB82fo6XnYT1XsO7HoHWpk9553N0RJD5n alex-taplab@taplab-204e" ];
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sXIx+I7BCq6T4QfiEWqvh+E1d9+y4CrTijURf5Wsq clamt" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKo8ils310ISB82fo6XnYT1XsO7HoHWpk9553N0RJD5n alex-taplab@taplab-204e" ];


  # Needed to run the VSCode SSH server.
  programs.nix-ld.enable = true;

  # For KDE Plasma debugging.
  environment.systemPackages = [ pkgs.libsForQt5.kdbusaddons ];
}
