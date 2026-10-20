{ inputs, lib, pkgs, ... }:
let
  # Master public keys in resources/veyon, named after who each belongs to.
  # "devops" is installed by services.veyon.publicKey below.
  masterKeys = [ "alex" "holly" "minecraft" "facilitators" ];

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

  # The configurator/CLI run `systemctl start veyon`, but the upstream module
  # names its unit veyon-service. Alias it so veyon.service resolves.
  systemd.services.veyon-service.aliases = [ "veyon.service" ];

  # Pre-authorise Veyon for KDE's remote desktop portal so the "special
  # privileges" prompt doesn't appear at every login. xdg-desktop-portal-kde
  # (isAppMegaAuthorized) looks up kde-authorized/"remote-desktop" for the
  # caller's app id; an empty app id covers host apps such as Xwayland, and
  # Veyon's own veyon-preauth-kde.sh uses "screencast", so grant all of them.
  # Results are logged: journalctl --user -u veyon-portal-preauth
  systemd.user.services.veyon-portal-preauth = {
    description = "Pre-authorise Veyon for KDE remote desktop";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      store() {
        ${pkgs.glib}/bin/gdbus call --session \
          --dest org.freedesktop.impl.portal.PermissionStore \
          --object-path /org/freedesktop/impl/portal/PermissionStore \
          --method "org.freedesktop.impl.portal.PermissionStore.$1" "''${@:2}"
      }

      for table in remote-desktop screencast; do
        for app in "" io.veyon.veyon-server; do
          store SetPermission "'kde-authorized'" true "'$table'" "'$app'" "['yes']" \
            || echo "SetPermission failed: table=$table app='$app'"
        done
        store Lookup "'kde-authorized'" "'$table'" || true
      done
    '';
  };

  # The upstream module only exposes a single named key via
  # services.veyon.publicKey, which drops it at /etc/veyon/keys/public/<name>/key.
  # Additional master keypairs (one per admin/user) are installed the same way.
  # Setting user/group/mode makes NixOS install real copies (replaced on each
  # activation) instead of store symlinks, owned by taplab:users.
  environment.etc =
    let
      keyFile = name: {
        user = "taplab";
        group = "users";
        mode = "0644";
      } // lib.optionalAttrs (name != "devops") { source = ../resources/veyon/${name}.pem; };
    in
    lib.listToAttrs (map
      (name: lib.nameValuePair "veyon/keys/public/${name}/key" (keyFile name))
      ([ "devops" ] ++ masterKeys))
    // {
      # System-wide Veyon config (QSettings system scope): authenticate with key
      # files only, and allow members of the "users" group.
      # Method is VeyonCore::AuthenticationMethod (0 = logon, 1 = key file).
      # UserGroups/Backend is the system user groups plugin, needed to resolve
      # group membership.
      "xdg/Veyon Solutions/Veyon.conf" = {
        mode = "0644";
        text = ''
        [Authentication]
        Method=1

        [AccessControl]
        AccessRestrictedToUserGroups=false
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
        DemoServerPort=11400

        [NetworkObjectDirectory]
        Plugin=14bacaaa-ebe5-449c-b881-5b382f952571

        [Service]
        FailedAuthenticationNotifications=false
      '';
      };
    };
}
