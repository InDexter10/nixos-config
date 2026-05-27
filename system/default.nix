{
  pkgs,
  ...
}:

{
  imports = [
    ./disko.nix
    ./users/dx0.nix
    ./global
    ./optional
    ./hardware-configuration.nix
    ./boot.nix
    ./network.nix
    ./sudo-rs.nix
    ./nix.nix
    ./others.nix

  ];

  system.nixos-init.enable = true;

  system.etc.overlay.enable = true;

  services.userborn.enable = true;

  users.users.root.hashedPassword = "$6$Oah9MF1tT4yGusND$cttjxDX346cb3pdo0JvZ9TLW.6tJNES72j89xfOn98kiC89gsW.xsWFdBz9znoiSObaToD69DRcUNFMwF6MQv1";

  system.stateVersion = "26.05";

}
