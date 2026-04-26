{ pkgs, ... }:

let
  focus = pkgs.writeShellApplication {
    name = "focus";
    runtimeInputs = with pkgs; [
      timewarrior
      rofi
      systemd
      jq
      coreutils
      gawk
    ];
    text = builtins.readFile ./focus.sh;
  };
in
{
  home.packages = [ focus ];
}
