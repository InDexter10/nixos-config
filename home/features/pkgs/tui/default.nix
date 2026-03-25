{ pkgs, ... }:

{
  imports = [
    ./yazi.nix
    ./helix.nix
    ./rio
  ];

  home.packages = with pkgs; [
    htop
    pavucontrol
  ];

}
