# This defines a custom nix package for GB Studio, and sets it up with an appimage wrapper.
{ fetchurl, appimageTools, stdenv }:

let
  pname = "gb-studio";
  version = "4.2.2";

  src = fetchurl {
    url = "https://github.com/chrismaltby/gb-studio/releases/download/v${version}/gb-studio-linux.AppImage";
    sha256 = "sha256-Kh6UgdleK+L+G4LNiQL2DkQIwS43cyzX+Jo6K0/fX1M=";
  };
in

appimageTools.wrapType2 { inherit pname version src; }
