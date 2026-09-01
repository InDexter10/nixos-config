{
  description = "NixOS 26.05 + standalone Home-Manager configuration for msi workstation";

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

      # Tek liste; hem NixOS hem Home-Manager tarafinda gecerli.
      allowedUnfree = [
        "corefonts" # system/modules/fonts.nix
        "claude-code" # home-manager/gui
      ];

      nixpkgsConfig = {
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
      };

      # unstable kanalini pkgs.unstable.<paket> olarak acar.
      # Su an tek tuketici: system/modules/labwc.nix
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
      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations.msi = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          {
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config = nixpkgsConfig;

            # nixos-version --configuration-revision ile gorulebilir.
            system.configurationRevision = self.rev or self.dirtyRev or "dirty";
          }
          ./system/default.nix
        ];
      };

      homeConfigurations."dex" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs self; };
        modules = [
          nix-flatpak.homeManagerModules.nix-flatpak
          ./home-manager/dex.nix
        ];
      };
    };
}
