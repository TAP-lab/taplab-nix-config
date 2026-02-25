{ config, pkgs, ... }:

{
  programs.wezterm.enable = true;

  home.file.".wezterm.lua".source = ../../resources/wezterm/wezterm.lua;

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}