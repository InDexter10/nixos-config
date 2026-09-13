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

  system.nixos-init.enable = false;
  system.etc.overlay.enable = false;
  services.userborn.enable = false;

  system.stateVersion = "26.05";
}
