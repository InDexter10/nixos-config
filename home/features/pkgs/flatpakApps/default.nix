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
      "io.github.celluloid_player.Celluloid"
      "com.github.tchx84.Flatseal"
      "org.kde.okular"
      "org.xfce.ristretto"
      #"com.github.jeromerobert.pdfarranger"
    ];

    overrides = {

      "org.mozilla.firefox" = {
        Context = {
          filesystems = [
            "xdg-downloads"
            "xdg-documents"
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

      "com.brave.Browser" = {
        Context = {
          filesystems = [
            "xdg-downloads"
            "!host"
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
            "xdg-downloads"
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

      "io.github.celluloid_player.Celluloid" = {
        Context = {
          filesystems = [
            "xdg-movies"
            "xdg-downloads"
            "!host"
          ];
          shared = [
            "!network"
            "!ipc"
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
            "xdg-downloads"
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
            "xdg-pictures"
            "xdg-downloads"
            "!host"
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
            "xdg-downloads"
            "!host"
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
