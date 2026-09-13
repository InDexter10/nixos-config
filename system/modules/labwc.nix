{ pkgs, ... }:

{
  programs.labwc = {
    enable = true;
    package = pkgs.unstable.labwc;
  };

  xdg.portal = {
    config.labwc.default = [
      "wlr"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
