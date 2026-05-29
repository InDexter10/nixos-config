{
  description = "NixOS 26.05 + Standalone Home-Manager configuration for msi workstation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        msi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./system/default.nix
          ];
        };
      };

      homeConfigurations = {
        "dex@msi" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/dex.nix
          ];
        };

        "virt0@msi" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/virt0.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];
        };

      };
    };
}
