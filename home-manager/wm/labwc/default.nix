# labwc/utils.nix
{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./fuzzel.nix
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
