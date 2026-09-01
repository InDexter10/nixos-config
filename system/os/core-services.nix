{ ... }:

{
  security = {
    rtkit.enable = true; # pipewire'in gercek zamanli onceligi icin
    polkit.enable = true;

    # Varsayilanlari zaten false; upstream degistirirse sistem sessizce
    # syscall kaydi biriktirmeye baslamasin diye sabitleniyor.
    audit.enable = false;
    auditd.enable = false;
  };

  # Kalici log bilincli olarak acik: 2026-08-29'daki Wi-Fi arizasi
  # "journalctl -b -1" ile teshis edildi. Sinir sart - varsayilan tavan
  # dosya sisteminin %10'u (bu diskte ~23 GB) ve disk sifresiz.
  #
  # MaxLevelStore kisitlanmadi: o arizada ise yarayan wpa_supplicant
  # satirlari info seviyesindeydi.
  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=200M
      SystemMaxFileSize=25M
      MaxRetentionSec=2week
    '';
  };

  # --- Varsayilan gelen, karsiligi olmayan bilesenler ---

  # espeak-ng dahil ~1.2 GiB kapanis. Ekran okuyucu kullanilmiyor;
  # gui/flatpakapps.nix da "speech-dispatcher kurulu degil" varsayimiyla
  # yazilmisti - o varsayim ancak bu satirla dogru hale geliyor.
  services.speechd.enable = false;

  # perl / rsync / strace. Ucu de kullanilmiyor; strace zaten
  # kernel.yama.ptrace_scope=2 altinda sudo'suz ise yaramaz.
  environment.defaultPackages = [ ];

  documentation = {
    # man sayfalari KALIYOR: "man configuration.nix" bu sistemde ogrenme
    # kaynagi. HTML manual da nixos.enable ile birlikte geliyor, ayrilamiyor.
    man.enable = true;
    nixos.enable = true;

    # Paketlerin share/doc ve info ciktilari. HTML dosyalari yalnizca
    # Flatpak tarayicidan acilabilir, o da /nix/store'u goremiyor;
    # info okuyucu da kurulu degil.
    doc.enable = false;
    info.enable = false;
  };
}
