# labwc/utils.nix
{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./rofi.nix
  ];
  xdg.configFile."labwc" = {
    source = ./configs;
    recursive = true;
  };
  home.packages = with pkgs; [
    swaybg
    wl-clipboard
    libnotify
  ];
}
