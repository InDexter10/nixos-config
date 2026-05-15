{ pkgs, ... }:

{
  imports = [
    ./yazi.nix
    ./helix.nix
    ./kitty.nix
  ];

  home.packages = with pkgs; [
    htop
    pavucontrol
  ];

}
