{ pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./uyap.nix
  ];

  home.packages = with pkgs; [

  ];

}
