{ pkgs, ... }:
{
  imports = [
  ];
  home.packages = with pkgs; [
    xarchiver

    opensnitch-ui

  ];

}
