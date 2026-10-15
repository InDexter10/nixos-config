{ lib, ... }:

let
  files = [
    "rc.xml"
    "menu.xml"
    "shutdown"
    "environment"
    "xinitrc"
    "themerc-override"
  ];
in
{
  wayland.windowManager.labwc = {
    enable = true;
    package = null; # paket sistemden: programs.labwc
  };

  xdg.configFile = lib.listToAttrs (
    map (f: lib.nameValuePair "labwc/${f}" { source = ./${f}; }) files
  );
}
