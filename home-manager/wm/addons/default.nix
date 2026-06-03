{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./rofi.nix
    ./ironbar.nix
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
