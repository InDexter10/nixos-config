{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    wireplumber.extraConfig."10-disable-bluetooth" = {
      "wireplumber.profiles".main."hardware.bluetooth" = "disabled";
    };
  };
}
