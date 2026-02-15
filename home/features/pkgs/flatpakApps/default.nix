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
      "io.gitlab.librewolf-community"
      "com.github.tchx84.Flatseal"
      "org.videolan.VLC"
      "org.kde.okular"
      "org.xfce.ristretto"
      #"com.github.jeromerobert.pdfarranger"
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

      "org.videolan.VLC" = {
        Context = {
          filesystems = [
            "!host"
            "!home"
          ];
          shared = [
            "!network"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            #"fallback-x11"
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

      "org.xfce.ristretto" = {
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
