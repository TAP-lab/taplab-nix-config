{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    inputs.disko.url = "github:nix-community/disko/latest";
    inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit (inputs) self;
            inherit inputs;
          };
          modules = [
            ./hardware-configuration.nix

            ./modules
            ./modules/apps
            ./modules/desktop
            ./modules/shell
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
                extraSpecialArgs = {
                  inherit (inputs) self;
                  inherit inputs;
                };
              };
            }
          ];
        };
      };
    };

    nixConfig = {
      experimentalFeatures = [
        "nix-command"
        "flakes"
        "auto-optimise-store"
      ];
    };
}
