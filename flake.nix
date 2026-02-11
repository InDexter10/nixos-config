{
  description = "MSI AIO - Fortress Workstation (25.11 Stable)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    steven-black-hosts.url = "github:StevenBlack/hosts";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
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
