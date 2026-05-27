{
  pkgs,
  mkNixPak,
  ...
}:

let
  vlc-sandboxed = mkNixPak {
    config =
      { sloth, ... }:
      {
        app.package = pkgs.vlc;
        flatpak.appId = "org.videolan.VLC";

        bubblewrap = {
          network = false;
          shareIpc = false;
          dieWithParent = true;
          newSession = true;

          sockets = {
            wayland = true;
            pipewire = true;
            pulse = true;
            x11 = false;
          };

          bind.rw = [
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.config/vlc"
              ]
            ))
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.cache/vlc"
              ]
            ))
            (sloth.mkdir (
              sloth.concat [
                sloth.homeDir
                "/.local/share/vlc"
              ]
            ))
          ];
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
          "org.mpris.MediaPlayer2.vlc" = "own";
        };
      };
  };
in
{
  home.packages = [ vlc-sandboxed.config.env ];
}
