{ ... }:

{
  services.fstrim.enable = true;

  # os/boot.nix cikarilabilir aygit modullerini onyukluyor, ama fstab'da
  # "user" secenegi olmadigi icin baglama yolu yoktu. udisks2 onu saglar;
  # ayri bir tepsi araci kurulmuyor:
  #   udisksctl mount   -b /dev/sda1     -> /run/media/dex/...
  #   udisksctl unmount -b /dev/sda1
  # polkit cikarilabilir aygitlar icin etkin oturuma parolasiz izin verir;
  # baglamalar nosuid + nodev alir.
  services.udisks2.enable = true;

  fileSystems = {
    "/".options = [ "noatime" ];

    # /boot yalnizca EFI ikilileri ve kernel imajlari tutar. Bootloader
    # guncellemesini bozmaz: bootctl /nix/store'dan calisir, /boot'a yalnizca
    # YAZAR (noexec yazmayi degil calistirmayi engeller).
    "/boot".options = [
      "nosuid"
      "nodev"
      "noexec"
    ];
  };
}
