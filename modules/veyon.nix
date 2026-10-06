{ inputs, pkgs, ... }:
let
  veyonPkg = pkgs.veyon.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.pipewire ];
    preInstall = (old.preInstall or "") + ''
      find . -name 'cmake_install.cmake' -exec sed -i \
        -e 's/[[:space:]]*SETUID//g' \
        -e 's/[[:space:]]*SETGID//g' \
        {} +
    '';
    postFixup = (old.postFixup or "") + ''
      for f in $out/share/polkit-1/actions/*.policy; do
        substituteInPlace "$f" \
          --replace "$out/bin/veyon-configurator" "$out/bin/.veyon-configurator-wrapped"
      done
    '';
  });
in
{
  imports = [ inputs.veyon.outputs.nixosModules.default ];

  nixpkgs.overlays = [
    (final: prev: {
      libdbusmenu-qt5 = (import inputs.nixpkgs { system = final.system; }).libdbusmenu-qt5;
    })
  ];

  services.veyon = {
    enable = true;
    publicKey = {
      name = "alex";
      value = builtins.readFile ../resources/veyon/alex.pub;
    };
    package = veyonPkg;
  };

  environment.systemPackages = [ veyonPkg ];

  # The upstream module only exposes a single named key via
  # services.veyon.publicKey, but it just drops the key at
  # /etc/veyon/keys/public/<name>/key - so additional master keypairs
  # (one per admin/user) are installed the same way here. Add one entry
  # per keypair, named after who it belongs to.
  environment.etc = {
    "veyon/keys/public/devops/key".source = ../resources/veyon/devops.pub;
    "veyon/keys/public/holly/key".source = ../resources/veyon/holly.pub;
    "veyon/keys/public/minecraft/key".source = ../resources/veyon/minecraft.pub;
    "veyon/keys/public/facilitators/key".source = ../resources/veyon/facilitators.pub;
  };
}
