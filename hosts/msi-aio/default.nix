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

    ../common/users/dex
    ../common/users/virt0
    ../common/global

    ../common/optional/labwc.nix
    ../common/optional/flatpak.nix
    #../common/optional/thunar.nix
    ../common/optional/greetd.nix
    ../common/optional/pipewire.nix

  ];

  system.stateVersion = "25.11";
}
