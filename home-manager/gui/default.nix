{ pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./uyap.nix
    ./vlc.nix
    ./okular.nix
    ./gwenview.nix
  ];

  home.packages = with pkgs; [
    chromium
  ];

}
