# Waybar zaman sayacinin paketi. Home-manager modulu DEGIL, paket dondurur:
#   let twTimer = import ./tw-timer.nix { inherit pkgs; }; in ...
#
# Betik ayri dosyada: Nix dizesi icinde her ${...} kacirmak zorunda kalmadan
# okunabilir kalsin ve writeShellApplication'in shellcheck denetiminden
# gecsin diye. Sabitler (37 dk vb.) betigin basindadir; baska tuketicisi yok.

{ pkgs }:

pkgs.writeShellApplication {
  name = "tw-timer";

  # PATH'e guvenilmez; her arac mutlak yolla cozulur.
  runtimeInputs = with pkgs; [
    timewarrior
    rofi
    jq
    libnotify
    coreutils
    util-linux # flock
  ];

  text = builtins.readFile ./tw-timer.sh;
}
