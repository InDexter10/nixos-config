{ lib, ... }:

{
  systemd.user.services.flatpak-managed-install.Install.WantedBy = lib.mkForce [ ];

  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    update.onActivation = false;
    update.auto.enable = false;

    restartOnFailure.enable = false;

    uninstallUnmanaged = true;

    packages = [
      "org.gtk.Gtk3theme.adw-gtk3-dark"

      "org.videolan.VLC"
      "org.mozilla.firefox"
      "org.kde.okular"
      "org.kde.gwenview"
      "com.github.jeromerobert.pdfarranger"
    ];

    overrides = {
      global = {
        Context = {
          sockets = [
            "wayland"
            "!inherit-wayland-socket"
            "!x11"
            "!fallback-x11"
            "!pulseaudio"
            "!ssh-auth"
            "!pcsc"
            "!cups"
            "!gpg-agent"
            "!session-bus"
            "!system-bus"
          ];

          filesystems = [
            "!host:reset"

            "!xdg-config/gtk-3.0"
            "!xdg-config/gtk-4.0"
            "xdg-config/gtk-3.0/settings.ini:ro"
            "xdg-config/gtk-3.0/gtk.css:ro"
            "xdg-config/gtk-4.0/settings.ini:ro"
            "xdg-config/gtk-4.0/gtk.css:ro"

            "xdg-config/kdeglobals:ro"

            "!host"
            "!home"
            "!host-os"
            "!host-etc"
            "!xdg-download"
            "!xdg-documents"
            "!xdg-desktop"
            "!xdg-pictures"
            "!xdg-music"
            "!xdg-videos"
            "!xdg-public-share"
            "!xdg-templates"

            "!xdg-run/gvfs"
            "!xdg-run/speech-dispatcher"

            "!/run/.heim_org.h5l.kcm-socket"

            "!xdg-cache/thumbnails"

            "!xdg-data/Trash"
          ];

          devices = [
            "!all"
            "!dri"
            "!input"
            "!usb"
            "!kvm"
            "!shm"
          ];

          shared = [
            "!network"
            "!ipc"
          ];

          features = [
            "!devel"
            "!bluetooth"
            "!canbus"
            "!multiarch"

            "!per-app-dev-shm"
          ];
        };

        "Session Bus Policy" = {
          "org.freedesktop.Flatpak" = "none";

          "org.freedesktop.secrets" = "none";
          "org.kde.kwalletd5" = "none";
          "org.kde.kwalletd" = "none";

          "org.gtk.vfs.*" = "none";
          "org.freedesktop.FileManager1" = "none";
          "org.a11y.Bus" = "none";

          "com.canonical.AppMenu.Registrar" = "none";
          "org.kde.KGlobalSettings" = "none";
          "org.kde.kconfig.notify" = "none";

          "org.freedesktop.ScreenSaver" = "none";
          "org.freedesktop.PowerManagement" = "none";
          "org.freedesktop.login1" = "none";

          "org.mpris.MediaPlayer2.Player" = "none";
        };

        "System Bus Policy" = {
          "org.freedesktop.NetworkManager" = "none";
        };

        Environment.QT_QPA_PLATFORMTHEME = "kde";
      };

      "org.videolan.VLC".Context = {
        devices = [ "dri" ];
        sockets = [
          "pulseaudio"
          "!wayland"
          "fallback-x11"
        ];
      };

      "org.mozilla.firefox".Context = {
        shared = [ "network" ];
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download:rw" ];
      };
    };
  };
}
