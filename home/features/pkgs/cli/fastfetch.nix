{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos";
        padding = {
          right = 2;
        };
      };
      display = {
        size = {
          binaryPrefix = "jedec";
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "disk"
        {
          type = "git"; # İşte aradığın modül!
          branch = true;
          commit = true;
          status = true;
        }
        "break"
        "colors"
      ];
    };
  };
}
