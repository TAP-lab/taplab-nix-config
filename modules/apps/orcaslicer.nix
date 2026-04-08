{ config, pkgs, ... }:

{
  # Copies the Orca Slicer config to automatically set up the 3d printers.
  home.activation.copyOrcaSlicerConfig = ''
    ${pkgs.gnutar}/bin/tar -xf ${../../resources/OrcaSlicer/OrcaSlicer.tar.xz} \
      -C ${config.home.homeDirectory}/.config/
  '';
}