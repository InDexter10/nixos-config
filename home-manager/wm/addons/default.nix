{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./rofi.nix
    ./conky.nix
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
