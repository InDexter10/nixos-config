{
  description = "NixOS 26.05 + Standalone Home-Manager configuration for msi workstation";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
  };
  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # unstable kanalını `pkgs.unstable.<paket>` olarak açar.
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          inherit (prev) config; # allowUnfree vb. tek yerden miras alınır
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay-unstable ];
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        msi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ overlay-unstable ]; }
            ./system/default.nix
          ];
        };
      };
      homeConfigurations = {
        "dex" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./home-manager/dex.nix
          ];
        };
      };
    };
}
