{ pkgs, ... }:

{
  programs.labwc = {
    enable = true;
    package = pkgs.unstable.labwc;
  };
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.labwc.default = [ "gtk" ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
