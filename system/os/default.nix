{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./core-services.nix
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
