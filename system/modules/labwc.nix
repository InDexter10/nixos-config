{ pkgs, ... }:

{
  programs.labwc = {
    enable = true;
    package = pkgs.unstable.labwc;
  };

  programs.fish.loginShellInit = ''
    if test -z "$WAYLAND_DISPLAY"; and test (tty) = /dev/tty1
        exec labwc
    end
  '';

  xdg.portal = {
    config.labwc = {
      default = [
        "wlr"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
