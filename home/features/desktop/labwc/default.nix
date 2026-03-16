# labwc/utils.nix
{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./fuzzel.nix
  ];

  home.packages = with pkgs; [
    swaybg # Arkaplan
    libnotify # Bildirim gönderme kütüphanesi
  ];
}
