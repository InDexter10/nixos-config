{ ... }:

{
  imports = [
    ./boot.nix
    ./core-services.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./sudo-rs.nix
    ./users.nix
  ];

  # Ucu de nixpkgs'te halihazirda false. Upstream varsayilani degistirdiginde
  # sistem sessizce yeni bir aktivasyon/kullanici yonetimi yoluna gecmesin
  # diye acikca sabitleniyorlar.
  #   etc.overlay nixpkgs tarafindan "currently experimental" isaretli.
  system.nixos-init.enable = false;
  system.etc.overlay.enable = false;
  services.userborn.enable = false;

  # Ilk kurulum surumu. ASLA guncellenmemeli.
  system.stateVersion = "26.05";
}
