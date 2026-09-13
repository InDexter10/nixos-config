{ pkgs, config, ... }:

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
      {
        timeout = 960;
        command = "${wlopm} --off '*'";
        resumeCommand = "${wlopm} --on '*'";
      }
    ];

    events.before-sleep = swaylock;
  };
}
