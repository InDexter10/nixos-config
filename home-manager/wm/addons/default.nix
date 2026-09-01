{ pkgs, ... }:

{
  imports = [
    ./mako.nix
    ./rofi.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wlsunset.nix
  ];

  home.packages = with pkgs; [
    swaybg # duvar kagidi
    wlopm # ekran gucu (DPMS); swayidle birimi mutlak yolla cagirir
    libnotify
    brightnessctl # logind uzerinden, udev kurali gerekmez
    wl-clipboard
    grim
    slurp
    wob # ses/parlaklik ekran ustu gostergesi
  ];
  # swayidle paketini ./swayidle.nix ekliyor; burada tekrarlanmaz.
}
