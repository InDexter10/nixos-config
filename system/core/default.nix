{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./boot.nix
    ./network.nix
    ./sudo-rs.nix
    ./nix.nix
    ./core-services.nix

  ];

  system.nixos-init.enable = false;

  system.etc.overlay.enable = false;

  services.userborn.enable = false;

  system.stateVersion = "26.05";

}
