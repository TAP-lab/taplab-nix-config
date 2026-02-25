{ pkgs ? import <nixpkgs> {}, icon }:

pkgs.stdenv.mkDerivation {
  pname = "gb-studio";
  version = "4.1.3";
  src = pkgs.fetchurl {
    url = "https://github.com/chrismaltby/gb-studio/releases/download/v4.1.3/gb-studio-linux.AppImage";
    sha256 = "45c2e83d852571bd8e143ddf990766cc383a2854e3a9a527dffc80b9089b99ed";
  };
  unpackPhase = "true";
  buildInputs = [ pkgs.appimage-run ];
  installPhase = ''
    mkdir -p $out/bin $out/share/appimage $out/share/applications $out/share/pixmaps
    cp $src $out/share/appimage/gb-studio-linux.AppImage
    cat > $out/bin/gb-studio <<EOF
    #!${pkgs.stdenv.shell}
    exec ${pkgs.appimage-run}/bin/appimage-run $out/share/appimage/gb-studio-linux.AppImage "\$@"
    EOF
    chmod +x $out/bin/gb-studio

    cat > $out/share/applications/gb-studio.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=GB Studio
    Exec=$out/bin/gb-studio
    Icon=gb-studio
    Terminal=false
    Categories=Development;Game;
    EOF

    cp ${icon} $out/share/pixmaps/gb-studio.png
  '';
  meta = with pkgs.lib; {
    description = "GB Studio (AppImage wrapper)";
    homepage = "https://github.com/chrismaltby/gb-studio";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
