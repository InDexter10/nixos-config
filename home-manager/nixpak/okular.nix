{
  pkgs,
  mkNixPak,
  ...
}:

let
  okular-sandboxed = mkNixPak {
    config =
      { sloth, ... }:
      {
        app.package = pkgs.kdePackages.okular;
        flatpak.appId = "org.kde.okular";

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
                "/.cache/okular"
              ]
            ))
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.local/share/okular"
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
  home.packages = [ okular-sandboxed.config.env ];
}
