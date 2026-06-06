{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./rofi.nix
    ./sfwbar.nix
  ];
  home.packages = with pkgs; [
    swaybg
    swayidle
    libnotify
    brightnessctl
    networkmanagerapplet
    wl-clipboard
    grim
    slurp
    wlopm

  ];
}
