{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./network.nix

    ./security

    ../common/users/dx
    ../common/users/virt0
    ../common/global

    ../common/optional/niri.nix
    ../common/optional/pipewire.nix
    ../common/optional/flatpak.nix
    ../common/optional/thunar.nix
    ../common/optional/greetd.nix

  ];

  system.stateVersion = "25.11";
}
