# This defines a custom nix package for GB Studio, and sets it up with an appimage wrapper.
{ fetchurl, appimageTools }:

let
  pname = "gb-studio";
  version = "4.3.2";

  src = fetchurl {
    url = "https://github.com/chrismaltby/gb-studio/releases/download/v${version}/gb-studio-linux.AppImage";
    sha256 = "sha256-EvI+h4l0+/y5esaQExVnpCxQ8mfQkKOeLDmOiLhpWOA=";
  };
in

appimageTools.wrapType2 { inherit pname version src; }
