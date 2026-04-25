{ pkgs, ... }:

{
  home.packages = [
    pkgs.waybar
  ];
  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/tw".source = ./tw;
}
