{ pkgs, ... }:

{
  home.packages = [ pkgs.nwg-panel ];
  #xdg.configFile."waybar/config".source = ./config.jsonc;
  #xdg.configFile."waybar/style.css".source = ./style.css;
}
