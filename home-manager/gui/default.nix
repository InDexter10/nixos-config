{ pkgs, ... }:
{
  imports = [
    ./flatpakapps.nix
    ./uyap.nix
  ];

  home.packages = with pkgs; [
    claude-code
  ];

}
