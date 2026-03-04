{ config, pkgs, ... }:

{
  # 1. KEEPASSXC: Şifre Kasası
  home.packages = with pkgs; [
    keepassxc
  ];

}
