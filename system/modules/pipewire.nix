{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # Bluetooth os/boot.nix'te kernel duzeyinde blacklist'li, ama wireplumber
    # yine de BlueZ monitorunu yukleyip her boot'ta
    # "spa.bluez5: BlueZ system service is not available" yaziyordu.
    #
    # hardware.video-capture BILEREK ELLENMIYOR: webcam'i PipeWire'a kaydeden
    # odur ve Flatpak Firefox kameraya Camera portali uzerinden o yoldan
    # ulasir. Kapatilirsa tarayicida kamera olmaz.
    wireplumber.extraConfig."10-disable-bluetooth" = {
      "wireplumber.profiles".main."hardware.bluetooth" = "disabled";
    };
  };
}
