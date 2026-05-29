{ pkgs, ... }:
{
  programs.labwc.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.labwc.default = [ "gtk" ];
  };
}
