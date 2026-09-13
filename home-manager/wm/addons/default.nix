{ pkgs, ... }:

let
  osd = import ./osd.nix { inherit pkgs; };
  power = import ./power.nix { inherit pkgs; };
in
{
  imports = [
    ./mako.nix
    ./rofi.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wlsunset.nix
  ];

  home.packages = [
    osd
    power
  ]
  ++ (with pkgs; [
    swaybg
    wlopm
    libnotify
    brightnessctl
    wl-clipboard
    grim
    slurp
    wob
  ]);
}
