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
      "com.brave.Browser"
      "io.gitlab.librewolf-community"
      "com.github.tchx84.Flatseal"
      "org.videolan.VLC"
      "org.kde.okular"
      "org.kde.gwenview"
      #"com.github.jeromerobert.pdfarranger"
    ];

    overrides = {
      "com.brave.Browser" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
          ];
          devices = [ "dri" ];
        };
        Environment = {
          "MOZ_ENABLE_WAYLAND" = "1";
        };
      };

      "io.gitlab.librewolf-community" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
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

      "org.videolan.VLC" = {
        Context = {
          filesystems = [
            "xdg-movies"
            "xdg-download"
            "!host"
          ];
          sockets = [
            "wayland"
            "pulseaudio"
            "x11"
          ];
          devices = [ "dri" ];
        };
      };

      "org.kde.okular" = {
        Context = {
          filesystems = [
            "xdg-download"
            "!host"
            "!home"
          ];
          sockets = [
            "wayland"
            "!x11"
          ];
        };
      };

      "org.kde.gwenview" = {
        Context = {
          filesystems = [
            "xdg-pictures"
            "xdg-download"
            "!host"
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
            "xdg-download"
            "!host"
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
