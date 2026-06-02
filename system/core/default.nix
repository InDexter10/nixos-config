{
  ...
}:

{
  imports = [
    #./hardware-configuration.nix
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

  users.users.root.hashedPassword = "$6$Oah9MF1tT4yGusND$cttjxDX346cb3pdo0JvZ9TLW.6tJNES72j89xfOn98kiC89gsW.xsWFdBz9znoiSObaToD69DRcUNFMwF6MQv1";

  system.stateVersion = "26.05";

}
