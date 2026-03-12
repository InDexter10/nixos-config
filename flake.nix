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

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 2. Noctalia Shell ana reposu
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs"; # Motoru bağla
    };

    fresh-editor = {
      url = "github:sinelaw/fresh";
      inputs.nixpkgs.follows = "nixpkgs"; # Senin sistemindeki nixpkgs ile uyumlu derlensin
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
      noctalia,
      fresh-editor,
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
