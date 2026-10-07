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
      name = "devops";
      value = builtins.readFile ../resources/veyon/devops.pem;
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
    # System-wide Veyon config (QSettings system scope): authenticate with
    # key files only, and restrict access to members of the "users" group.
    # Method is VeyonCore::AuthenticationMethod (0 = logon, 1 = key file).
    # UserGroups/Backend is the system user groups plugin, needed to resolve
    # group membership.
    "xdg/Veyon Solutions/Veyon.conf".text = ''
      [Authentication]
      Method=1

      [AccessControl]
      AccessRestrictedToUserGroups=true
      AuthorizedUserGroups=users

      [UserGroups]
      Backend={2917cdeb-ac13-4099-8715-20368254a367}
      UseDomainUserGroups=false

      [Master]
      AllowAddingHiddenLocations=false
      AutoAdjustMonitoringIconSize=false
      AutoOpenComputerSelectPanel=false
      AutoSelectCurrentLocation=false
      ComputerMonitoringSortOrder=0
      ComputerMonitoringVisibilityMode=2
      ConfirmUnsafeActions=false
      HideComputerFilter=true
      HideEmptyLocations=true
      HideLocalComputer=true
      HideOwnSession=true
      ShowCurrentLocationOnly=false

      [Network]
      VeyonServerPort=11100

      [NetworkObjectDirectory]
      Plugin=14bacaaa-ebe5-449c-b881-5b382f952571

      [Service]
      FailedAuthenticationNotifications=false
    '';

    "veyon/keys/public/alex/key".source = ../resources/veyon/alex.pem;
    "veyon/keys/public/holly/key".source = ../resources/veyon/holly.pem;
    "veyon/keys/public/minecraft/key".source = ../resources/veyon/minecraft.pem;
    "veyon/keys/public/facilitators/key".source = ../resources/veyon/facilitators.pem;
  };
}
