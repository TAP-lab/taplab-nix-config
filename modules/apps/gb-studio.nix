# This defines a custom nix package for GB Studio, and sets it up with an appimage wrapper.
{ fetchurl, appimageTools, stdenv }:

let
  pname = "gb-studio";
  version = "4.2.2";

  src = fetchurl {
    url = "https://github.com/chrismaltby/gb-studio/releases/download/v${version}/gb-studio-linux.AppImage";
    sha256 = "sha256-GscN9nFyDqgTEgx9bQI78blDJOlynkZX83cgqLIHkQ8=";
  };
in

appimageTools.wrapType2 { inherit pname version src; }
