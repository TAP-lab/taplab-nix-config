{ ... }:

{
  # Sets up the home manager configuration for the taplab user.
  home.stateVersion = "25.11";

  # Enables the nix command, and flakes.
  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    accept-flake-config = true
  '';
}
