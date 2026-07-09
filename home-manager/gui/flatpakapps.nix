{ ... }:

{
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

    uninstallUnmanaged = true;

    packages = [
      "org.videolan.VLC"
      "org.mozilla.firefox"
      "io.gitlab.librewolf-community"
      "org.kde.okular"
      "org.kde.gwenview"
      "com.github.jeromerobert.pdfarranger"
    ];

    overrides = {
      global = {
        Context = {
          sockets = [
            "wayland"
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
          ];
          devices = [
            "!all"
            "!dri"
            "!input"
            "!usb"
            "!kvm"
            "!shm"
          ];
          shared = [ "!network" ];
          features = [
            "!devel"
            "!bluetooth"
            "!canbus"
          ];
        };
        "Session Bus Policy" = {
          "org.freedesktop.Flatpak" = "none";
        };
      };

      "org.videolan.VLC".Context = {
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        # filesystems = [ "xdg-videos:ro" "xdg-download:ro" ];
      };

      "org.mozilla.firefox".Context = {
        shared = [ "network" ];
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download:rw" ];
      };

      "io.gitlab.librewolf-community".Context = {
        shared = [ "network" ];
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download:rw" ];
      };

    };
  };
}
