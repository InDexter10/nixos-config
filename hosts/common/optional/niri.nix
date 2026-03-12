{ pkgs, lib, ... }:

{
  programs.niri.enable = true;

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
