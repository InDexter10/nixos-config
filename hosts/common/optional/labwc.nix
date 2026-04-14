{ pkgs, pkgs-unstable, ... }:

{
  programs.labwc = {
    enable = true;
    package = pkgs-unstable.labwc;
  };
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    config.labwc = {
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      "org.freedesktop.impl.portal.Inhibit" = "none";
      default = "gtk";
    };
  };
}
