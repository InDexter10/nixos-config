{ pkgs, ... }:

{
  users.users.dex = {
    isNormalUser = true;
    description = "main user";
    hashedPassword = "$6$JouoR1RwEJ9QMpXD$m2lMN76lf1XA9hhLmanvCJ28GjgnEt/R0sVhkB/P/57YovKZNuZ6Pt.h1Sge180Kuj5tQXRNqHFRxbaP9fGP01";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "trq";
}
