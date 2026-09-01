{ pkgs, config, ... }:

# Otomatik kilit. systemd birimi olmasi sart: labwc/autostart icinde ciplak
# bir arkaplan sureciyken cokerse yeniden baslamiyor, hicbir yere log
# dusmuyor ve makine sessizce kilitlenmez oluyordu.
#
# DIKKAT: home-manager bu birime PATH olarak YALNIZCA bash veriyor, komutlar
# sh -c ile calisiyor. Ciplak "swaylock" yazmak calismaz - mutlak yol sart.

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock -f";
  wlopm = "${pkgs.wlopm}/bin/wlopm";
in
{
  services.swayidle = {
    enable = true;

    timeouts = [
      {
        timeout = 900;
        command = swaylock;
      }
      # Kilit bir dakika once girdigi icin ekran uyandiginda dogrudan parola
      # ekrani gelir.
      {
        timeout = 960;
        command = "${wlopm} --off '*'";
        resumeCommand = "${wlopm} --on '*'";
      }
    ];

    events.before-sleep = swaylock;
  };
}
