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
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Izin verilen unfree paketler. Tek liste, hem NixOS hem Home-Manager
      # tarafinda gecerli; yeni bir unfree paket eklemek icin buraya adini yaz.
      allowedUnfree = [
        "corefonts" # Times New Roman + Arial (system/modules/fonts.nix)
        "claude-code" # home-manager/cli
      ];

      # Hem sistem hem home tarafinin paylastigi nixpkgs ayari.
      nixpkgsConfig = {
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
      };

      # unstable kanalini `pkgs.unstable.<paket>` olarak acar.
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          inherit (prev) config; # unfree politikasi tek yerden miras alinir
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay-unstable ];
        config = nixpkgsConfig;
      };
    in
    {
      # `nix fmt` -> helix'in kullandigi formatter ile ayni.
      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations = {
        msi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            {
              nixpkgs.overlays = [ overlay-unstable ];
              nixpkgs.config = nixpkgsConfig;

              # Calisan sistemin hangi commit'ten geldigini kaydeder:
              # `nixos-version --configuration-revision` ile gorulebilir.
              system.configurationRevision = self.rev or self.dirtyRev or "dirty";
            }
            ./system/default.nix
          ];
        };
      };
      homeConfigurations = {
        "dex" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs self; };
          modules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./home-manager/dex.nix
          ];
        };
      };
    };
}
