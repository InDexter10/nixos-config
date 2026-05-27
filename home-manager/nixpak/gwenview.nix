{
  pkgs,
  mkNixPak,
  ...
}:

let
  gwenview-sandboxed = mkNixPak {
    config =
      { sloth, ... }:
      {
        app.package = pkgs.kdePackages.gwenview;
        flatpak.appId = "org.kde.gwenview";

        bubblewrap = {
          network = false;
          shareIpc = false;
          dieWithParent = true;
          newSession = true;

          sockets = {
            wayland = true;
            pipewire = false;
            pulse = false;
            x11 = false;
          };

          bind.rw = [
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.config"
              ]
            ))
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.cache/gwenview"
              ]
            ))
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.local/share/gwenview"
              ]
            ))
          ];

          env = {
            QT_QPA_PLATFORM = "wayland";
          };
        };

        gpu = {
          enable = true;
          provider = "nixos";
        };

        dbus.policies = {
          "org.freedesktop.portal.Desktop" = "talk";
          "org.freedesktop.portal.Documents" = "talk";
          "org.freedesktop.portal.FileChooser" = "talk";
          "org.freedesktop.Notifications" = "talk";
        };
      };
  };
in
{
  home.packages = [ gwenview-sandboxed.config.env ];
}
