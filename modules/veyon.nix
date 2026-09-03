{ inputs, ... }:
{
  imports = [ inputs.veyon.outputs.nixosModules.default ];

  # The veyon flake's package derivation references a top-level
  # `libdbusmenu-qt5` package that doesn't exist in nixpkgs - it's
  # `libsForQt5.libdbusmenu` there. Alias it so the veyon overlay resolves.
  nixpkgs.overlays = [
    (final: prev: {
      libdbusmenu-qt5 = final.libsForQt5.libdbusmenu;
    })
  ];

  services.veyon = {
    enable = true;
    publicKey = {
      name = "alex";
      value = builtins.readFile ../resources/veyon/alex.pub;
    };
  };

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
