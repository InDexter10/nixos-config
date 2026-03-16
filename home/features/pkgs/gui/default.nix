{ pkgs, ... }:
{
  imports = [
  ];
  home.packages = with pkgs; [

    opensnitch-ui
    zenity # applowy için
    appflowy
  ];

}
