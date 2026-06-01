{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./rofi.nix
    ./ironbar.nix
  ];
  home.packages = with pkgs; [
    swaybg
    swayidle
    libnotify
    brightnessctl
    networkmanagerapplet
    wlsunset
    wl-clipboard
    grim
    slurp
    wlopm

  ];
}
