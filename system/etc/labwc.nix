{ pkgs, ... }:
{
  programs.labwc.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.labwc.default = [ "gtk" ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Nix-paketli Electron/Chromium native Wayland
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt önce Wayland; yoksa XWayland'a düş
  };

}
