{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-old,
    home-manager,
    plasma-manager,
    ...
  }:
  {
    nixosConfigurations = {
      nixos = let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
      in nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          ./hardware-configuration.nix

          ./modules/configuration.nix
          ./modules/pkgs.nix
          ./modules/nas.nix

          ./modules/debug.nix

          ./modules/desktop/kde.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                nixpkgs-unstable = nixpkgs-unstable;
                nixpkgs-old = nixpkgs-old;
                self = self;
              };
              sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              users.taplab = { pkgs, ... }: {
                imports = [
                  ./modules/home.nix

                  ./modules/shell/zsh.nix
                  ./modules/shell/themes/taplab-theme.nix

                  ./modules/desktop/plasma-manager.nix

                  ./modules/apps/wezterm.nix
                  ./modules/apps/minecraft.nix
                  ./modules/apps/orcaslicer.nix
                ];
              };
            };
          }
        ];
        specialArgs = {
          inherit nixpkgs-unstable;
          inherit nixpkgs-old;
          inherit self;
        };
      };
    };
  };
}
