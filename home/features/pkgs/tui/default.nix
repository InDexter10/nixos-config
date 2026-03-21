{ pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./yazi.nix
    ./helix.nix
  ];

  home.packages = with pkgs; [
    htop
    wezterm
    rio
    pavucontrol
  ];

}
