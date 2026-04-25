{ pkgs, lib, ... }:

{
  services.flatpak = {
    enable = true;

    update.onActivation = false;

    uninstallUnmanaged = true;

    remotes = lib.mkOptionDefault [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "org.mozilla.firefox"
      "com.brave.Browser"
      #"io.gitlab.librewolf-community"
      "com.github.tchx84.Flatseal"
      "org.kde.okular"
      "org.kde.gwenview"
      "com.github.jeromerobert.pdfarranger"
      "io.github.celluloid_player.Celluloid"
    ];

    overrides = {

      "org.mozilla.firefox" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
            "!home"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            "!x11"
          ];
          devices = [ "dri" ];
        };
        Environment = {
          "MOZ_ENABLE_WAYLAND" = "1";
        };
      };

      "com.brave.Browser" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
            "home"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            "!x11"
          ];
          devices = [ "dri" ];
        };
      };

      "io.gitlab.librewolf-community" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
            "!home"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            "!x11"
          ];
          devices = [ "dri" ];
        };
      };

      "org.kde.okular" = {
        Context = {
          filesystems = [
            "!host"
            "!home"
          ];
          shared = [
            "!network"
            "!ipc"
          ];
          sockets = [
            "wayland"
            "!x11"
          ];
        };
      };

      "io.github.celluloid_player.Celluloid" = {
        Context = {
          filesystems = [
            "~/Movies"
            "!home"
            "!host"
            "!xdg-pictures" # Resimlere erişimi açıkça reddet
            "!xdg-run/gvfs" # Ağ bağlantılı disklere erişimi reddet
            "!xdg-run/gvfsd"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            "!x11" # X11'i açıkça reddet
            "!fallback-x11" # Yedek X11'i açıkça reddet
          ];
          shared = [
            "ipc"
            "!network"
          ];
          devices = [
            "dri"
            "!all" # Diğer tüm donanımları açıkça reddet
          ];
        };
      };

      "com.github.jeromerobert.pdfarranger" = {
        Context = {
          filesystems = [
            "!host"
            "!home"
          ];
          shared = [
            "!network"
            "!ipc"
          ];
          sockets = [
            "wayland"
            "!x11"
          ];
        };
      };
    };
  };
}
