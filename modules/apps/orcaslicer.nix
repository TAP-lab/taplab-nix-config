{ config, pkgs, ... }:

{
  home.activation.copyOrcaSlicerConfig = ''
    mkdir -p ${config.home.homeDirectory}/.config/OrcaSlicer
    ${pkgs.gnutar}/bin/tar -xf ${../../resources/OrcaSlicer/OrcaSlicer.tar.xz} \
      -C ${config.home.homeDirectory}/.config/OrcaSlicer
  '';
}