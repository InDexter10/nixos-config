{ pkgs, ... }:
{
  imports = [
    ./uyap.nix
  ];
  home.packages = with pkgs; [
    #xarchiver

    opensnitch-ui

  ];

}
