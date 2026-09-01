{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ]; # VAAPI donanim video cozumu
  };

  hardware.cpu.intel.updateMicrocode = true;

  # Wi-Fi (iwlwifi) icin zorunlu. linux-firmware ~780 MiB ile closure'daki
  # en buyuk tek kalem; daraltmak Wi-Fi'yi kirma riski tasidigi icin
  # bilincli olarak dokunulmuyor.
  hardware.enableRedistributableFirmware = true;
}
