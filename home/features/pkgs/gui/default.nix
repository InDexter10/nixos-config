{ pkgs, ... }:
{
  imports = [
    # ./firefox.nix
  ];
  home.packages = with pkgs; [

    opensnitch-ui
    zenity # applowy için
    appflowy
    (pkgs.writeShellScriptBin "zed" ''
      WAYLAND_DISPLAY="" exec ${pkgs.zed-editor}/bin/zeditor "$@"
    '')
  ];

  xdg.desktopEntries.zed = {
    name = "Zed";
    exec = "env WAYLAND_DISPLAY=\"\" zeditor %F";
    icon = "zed";
    terminal = false;
    type = "Application";
    categories = [
      "TextEditor"
      "Development"
    ];
  };

}
