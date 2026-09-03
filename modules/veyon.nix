{ inputs, ... }:
{
  imports = [ inputs.veyon.outputs.nixosModules.default ];

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
