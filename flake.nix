{
  description = "MSI AIO - Fortress Workstation (25.11 Stable)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      dms,
      dgop,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgsConfig = {
        allowUnfree = true;
      };

    in
    {
      nixosConfigurations = {
        msi-aio = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/msi-aio/default.nix

            {
              nixpkgs.config = pkgsConfig;
            }
          ];
        };
      };

      homeConfigurations = {
        "virt0" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = pkgsConfig;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/virt0.nix
            nix-flatpak.homeManagerModules.nix-flatpak
            inputs.dms.homeModules.dank-material-shell

          ];
        };

        "dx" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = pkgsConfig;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/dx.nix
            nix-flatpak.homeManagerModules.nix-flatpak

          ];
        };

      };
    };
}
