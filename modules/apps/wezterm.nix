{ config, pkgs, ... }:

{
  # Sets up WezTerm - mainly used for developing the config.
  programs.wezterm.enable = true;

  home.file.".wezterm.lua".source = ../../resources/wezterm/wezterm.lua;

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}