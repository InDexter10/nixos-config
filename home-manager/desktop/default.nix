{ pkgs, ... }:

{
  imports = [
    ./mime.nix
    ./userdirs.nix
  ];

  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "DMZ-White";
    size = 20;
  };
}
