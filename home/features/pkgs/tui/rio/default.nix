{ pkgs, pkgs-unstable, ... }:

{
  programs.rio = {
    enable = true;
    package = pkgs-unstable.labwc;
  };
  xdg.configFile."rio" = {
    source = ./configs;
    recursive = true;
  };
}
