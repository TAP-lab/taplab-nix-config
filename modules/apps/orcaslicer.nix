{ config, pkgs, ... }:

{
  home.activation.copyOrcaSlicerConfig = ''
    ${pkgs.gnutar}/bin/tar -xf ${../../resources/OrcaSlicer/OrcaSlicer.tar.xz} \
      -C ${config.home.homeDirectory}/.config/
  '';
}