# labwc/utils.nix
{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./fuzzel.nix
  ];
  xdg.configFile."labwc" = {
    source = ./configs;
    recursive = true; # Eğer ileride alt klasör eklersen onları da kapsar
  };
  home.packages = with pkgs; [
    swaybg
    libnotify
  ];
}
