{
  description = "MSI AIO - Fortress Workstation (25.11 Stable)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      extraSpecialArgs = { inherit inputs pkgs-unstable; };
    in
    {
      nixosConfigurations = {
        msi-aio = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs pkgs-unstable; };
          modules = [
            ./hosts/msi-aio/default.nix
            { nixpkgs.pkgs = pkgs; }
          ];
        };
      };

      homeConfigurations = {
        "virt0" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;
          modules = [
            ./home/virt0.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];
        };

        "dex" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;
          modules = [
            ./home/dex.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];
        };
      };
    };
}
