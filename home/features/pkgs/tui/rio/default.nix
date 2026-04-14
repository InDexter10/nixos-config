{ pkgs, pkgs-unstable, ... }:

{
  programs.rio = {
    enable = true;
    package = pkgs-unstable.rio;
  };
  xdg.configFile."rio" = {
    source = ./configs;
    recursive = true;
  };
}
