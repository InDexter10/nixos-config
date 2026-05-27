# labwc/utils.nix
{ pkgs, ... }:

{

  imports = [
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
