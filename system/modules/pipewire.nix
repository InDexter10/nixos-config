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

    # MIDI cihazi yok; lockKernelModules snd_seq'in sonradan yuklenmesini engeller.
    wireplumber.extraConfig."10-disable-midi" = {
      "wireplumber.profiles".main."monitor.alsa-midi" = "disabled";
    };
  };
}
