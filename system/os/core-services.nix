{ ... }:

{
  security = {
    # PipeWire'in gercek zamanli zamanlama onceligi alabilmesi icin gerekli.
    # services.pipewire etkin oldugu surece kaldirilamaz.
    rtkit.enable = true;

    # NetworkManager modulu zaten zorunlu kiliyor; niyet gorunur olsun diye
    # burada acikca yaziliyor.
    polkit.enable = true;

    # Kernel denetim (audit) altyapisi. Varsayilani zaten false; tek kullanicili
    # bir masaustunde okunmayan syscall kaydi biriktirmekten baska ise yaramaz
    # (kural 11). Upstream varsayilani degisirse sistem sessizce log uretmeye
    # baslamasin diye acikca sabitleniyor.
    audit.enable = false;
    auditd.enable = false;
  };

  # --- Journald ---
  #
  # Kalici log BILEREK acik: 2026-08-29'daki Wi-Fi arizasi tam olarak
  # "journalctl -b -1" sayesinde teshis edildi. Kural 11'in "zaruri olanlar
  # acik birakilacak" istisnasi budur.
  #
  # Ama sinirsiz birakilamazdi. Varsayilan tavan dosya sisteminin %10'u - bu
  # diskte ~23 GB. Olcum: 3 aylik kullanimda 427 MB birikmisti, hicbir sinir
  # yoktu. Disk sifresiz oldugu icin (kural 7) bu, hangi aglara baglandigin,
  # hangi cihazlari taktigin, oturum saatlerin gibi ayrintili bir davranis
  # kaydinin diskte suresiz durmasi demektir (kural 2).
  #
  # MaxLevelStore BILEREK kisitlanmadi: Wi-Fi teshisinde ise yarayan
  # wpa_supplicant satirlari info seviyesindeydi. Onem seviyesini kisip
  # teshis yetenegini kaybetmek yerine boyut ve sure sinirlaniyor.
  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=200M
      SystemMaxFileSize=25M
      MaxRetentionSec=2week
    '';
  };
}
