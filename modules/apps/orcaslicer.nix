{ config, pkgs, ... }:

{
  home.activation.copyOrcaSlicerConfig = ''
    mkdir -p ${config.home.homeDirectory}/.config/OrcaSlicer
    ${pkgs.gnutar}/bin/tar -xJf ${../../resources/OrcaSlicer/OrcaSlicer.tar.xz} \
      -C ${config.home.homeDirectory}/.config/OrcaSlicer
  '';
}