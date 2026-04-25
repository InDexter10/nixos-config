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

    ../common/users/rai
    ../common/users/virt0
    ../common/global

    ../common/optional/labwc.nix
    ../common/optional/flatpak.nix
    ../common/optional/greetd.nix
    ../common/optional/pipewire.nix

  ];

  system.nixos-init.enable = true;

  system.etc.overlay.enable = true;

  services.userborn.enable = true;

  users.users.root.hashedPassword = "$6$Oah9MF1tT4yGusND$cttjxDX346cb3pdo0JvZ9TLW.6tJNES72j89xfOn98kiC89gsW.xsWFdBz9znoiSObaToD69DRcUNFMwF6MQv1";

  system.stateVersion = "25.11";

}
