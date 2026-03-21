{ pkgs, ... }:

{
  programs.labwc.enable = true;
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

      # İŞTE KATİLİ ÖLDÜREN SATIR:
      # Firefox "ekran kapanmasın" dediğinde arama yapma, anında reddet ki donma olmasın.
      "org.freedesktop.impl.portal.Inhibit" = "none";

      default = "gtk";
    };
  };
}
