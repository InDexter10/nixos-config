{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./ironbar.nix
    ./rofi.nix
  ];
  home.packages = with pkgs; [
    ironbar
    swaybg
    swayidle
    mako
    libnotify
    brightnessctl
    networkmanagerapplet
    wlsunset
    wlomp
    wl-clipboard
    grim
    slurp

  ];
}
