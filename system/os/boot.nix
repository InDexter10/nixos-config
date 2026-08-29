{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;
    tmp.cleanOnBoot = true;

    consoleLogLevel = 3;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;

        # Boot menusunden kernel komut satirinin duzenlenmesini engeller
        # (ornegin init=/bin/sh ile parolasiz root shell alinmasini).
        # security.protectKernelImage bunu KENDILIGINDEN yapmiyor - bu satir
        # gerekli, silinmemeli.
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    # security.lockKernelModules = true oldugu icin sistem tam acildiktan sonra
    # HICBIR modul yuklenemez. Sonradan takilan USB bellek / harici disk / SD
    # kart icin gereken moduller boot'ta yuklenmis olmali, yoksa cihaz hic
    # gorunmez. (usb-storage.ko dosya adi tireli; modprobe iki yazimi da cozer.)
    kernelModules = [
      "usb_storage"
      "uas"
      "sd_mod"
      "exfat"

      # Wi-Fi: bu uc de talep uzerine yuklenen modul, kilit yuzunden onceden
      # yuklenmis olmali.
      # af_packet: wpa_supplicant ve NM'in dahili DHCP istemcisi AF_PACKET
      #   soketi acar (CONFIG_PACKET=m). Yuklu degilse
      #   "wpa_supplicant couldn't grab this interface" -> ag listesi bos kalir.
      #   2026-08-29'daki ilk switch bu sekilde kirildi.
      # ccm + aes: WPA2/CCMP sifrelemesi, iliskilendirme aninda istenir.
      #   Eksikse aglar gorunur ama baglanti kurulamaz. (ccm kendi bagimliligi
      #   aead'i otomatik ceker; aes crypto API'nin calisma aninda cozdugu bir
      #   sablon oldugu icin ayrica listelenmeli.)
      # NOT: WPA3/PMF kullanan bir aga baglanilamazsa eksik olan "cmac",
      #   WPA3-Enterprise icin "gcm" olabilir; o zaman buraya eklenir.
      "af_packet"
      "ccm"
      "aes"
    ];

    # NOT: lockKernelModules aktif oldugu icin boot'ta yuklenmemis her modul
    # zaten yuklenemez durumda. Bu yuzden liste bilincli olarak kisa tutuldu;
    # "her ihtimale karsi" uzun blacklist listeleri burada gereksiz tekrar
    # olurdu (kural 3 ve 4). Liste sadece BOOT SIRASINDA otomatik yuklenebilecek
    # modulleri hedefler.
    blacklistedKernelModules = [
      # Kullanilmayan ag protokolleri
      "dccp"
      "sctp"
      "rds"
      "tipc"

      # Kullanilmayan donanim ve veri yollari (kural 12)
      "firewire-core"
      "thunderbolt"
      "floppy"
      "cdrom"
      "bluetooth"
      "btusb"

      # Sanallastirma kullanilmiyor. kvm + kvm_intel ~1.9 MB kernel kodu ve
      # genis bir saldiri yuzeyi; refcount 0 ile bosuna yukluydu (kural 3).
      "kvm"
      "kvm-intel"

      # msr: userspace'ten ham CPU model-specific register okuma/yazma arayuzu.
      # joydev: oyun kolu surucusu, kullanilmiyor.
      #
      # DIKKAT: thermald bazi Intel okumalarini MSR uzerinden yapabilir.
      # Switch sonrasi kontrol: journalctl -u thermald -p warning
      # Sorun cikarsa "msr" bu listeden cikarilmali.
      "msr"
      "joydev"
    ];

    kernelParams = [
      "quiet"
      "udev.log_priority=3"

      # --- Bellek sertlestirme ---
      "init_on_alloc=1"
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      # init_on_free BILEREK KAPALI: Celeron N4000'de %1-3 performans bedeli
      # var, kullanici tercihi. Acmak icin buraya "init_on_free=1" eklemek yeterli.

      # --- IOMMU / DMA ---
      # intel_iommu tek basina "lazy" modda calisir; strict + passthrough=0 ile
      # DMA eslemeleri hemen gecersiz kilinir.
      "intel_iommu=on"
      "iommu.strict=1"
      "iommu.passthrough=0"
      "efi=disable_early_pci_dma"

      "vsyscall=none"
      "debugfs=off"

      # IPv6'yi kernel duzeyinde tamamen kapatir. networking.enableIPv6 = false
      # sadece sysctl ayarliyor, bu parametreyi otomatik EKLEMIYOR - ikisi de
      # gerekli.
      "ipv6.disable=1"

      # --- BILEREK EKLENMEYENLER ---
      #
      # lockdown=confidentiality: Bu kernelde CONFIG_SECURITY_LOCKDOWN_LSM
      # derlenmemis, parametre sessizce yok sayilirdi (yani sahte guvenlik).
      # Ustelik CONFIG_MODULE_SIG de kapali; lockdown gercekten etkin olsaydi
      # imzasiz modul yuklemeyi engelledigi icin ext4/nvme yuklenemez ve sistem
      # hic acilmazdi.
      #
      # mitigations=* / nosmt: Celeron N4000'de SMT yok (1 thread/core) ve
      # lscpu'ya gore spekulatif aciklarin cogu "Not affected". Kernel
      # varsayilanlari yeterli; ek parametrenin karsiligi yok.
    ];

    kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";

      "kernel.sysrq" = 0;

      # 2 = yalnizca root / CAP_SYS_PTRACE attach edebilir.
      # YAN ETKI: normal kullanici olarak gdb / strace / perf ile KENDI
      # sureclerini bile inceleyemezsin, sudo gerekir.
      # Hata ayiklama gerekirse 1 yap (sadece kendi cocuk sureclerine izin verir)
      # ve rebuild et. 3 GERI DONUSSUZDUR, kullanma.
      "kernel.yama.ptrace_scope" = 2;

      "kernel.unprivileged_bpf_disabled" = 1;
      # BPF JIT sertlestirme. net.* namespace'inde olsa da konusu BPF oldugu
      # icin ustteki satirla birlikte burada tutuluyor.
      "net.core.bpf_jit_harden" = 2;

      "kernel.io_uring_disabled" = 2;
      "kernel.perf_event_paranoid" = 3;
      "vm.unprivileged_userfaultfd" = 0;

      # flatpak / bwrap ve nix sandbox user namespace'e ihtiyac duyar.
      # 0 yapmak bu sistemi calisamaz hale getirir (kural 1 ve 6).
      "user.max_user_namespaces" = 500;

      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;

      "dev.tty.ldisc_autoload" = 0;

      # net.ipv4.* ag sysctl'leri os/network.nix icinde (kural 6).
    };

    extraModprobeConfig = ''
      install dccp ${pkgs.coreutils}/bin/false
      install sctp ${pkgs.coreutils}/bin/false
      install rds ${pkgs.coreutils}/bin/false
      install tipc ${pkgs.coreutils}/bin/false

      # msr yukaridaki blacklist'te de var, ama "blacklist" yalnizca ALIAS
      # uzerinden otomatik yuklemeyi engeller; bir sey acikca "modprobe msr"
      # cagirirsa engellemez ve modul yine yuklenir (ilk switch'te oyle oldu).
      # Bu satir yuklemeyi kesin olarak blokler.
      # Dogrulandi: /dev/cpu/*/msr'yi acik tutan surec yok ve thermald sifir
      # uyariyla calisiyor, yani kimse bu module ihtiyac duymuyor.
      install msr ${pkgs.coreutils}/bin/false

      options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
      options iwlmvm power_scheme=1
    '';
  };

  # nohibernate + kernel.kexec_load_disabled=1 (calisan kernel'in
  # degistirilmesini engeller).
  security.protectKernelImage = true;

  # Sistem tam olarak acildiktan sonra (udev settle sonrasi) modul yuklemeyi
  # kalici olarak kapatir: /proc/sys/kernel/modules_disabled = 1.
  # Bir modul eksik cikarsa boot.kernelModules'e eklenip REBOOT edilmeli;
  # calisirken duzeltilemez.
  security.lockKernelModules = true;

  # --- Core dump'lar ---
  # Core dump cokmus surecin TUM bellek icerigini (parolalar, oturum token'lari,
  # cozulmus veriler) diske yazar. Disk sifresiz oldugu icin (kural 7) bu kalici
  # bir mahremiyet riskidir.
  #
  # DIKKAT: systemd.coredump.enable = false TEK BASINA YETMEZ. NixOS modulunun
  # kendi belgesi soyle diyor: "If disabled, core dumps appear in the current
  # directory of the crashing process." Yani kernel.core_pattern "core" olur ve
  # dump'lar tek bir root-only dizin yerine surecin calisma dizinine (ev dizini
  # dahil) dagilir - durum iyilesmek yerine KOTULESIR.
  #
  # Gercek cozum RLIMIT_CORE'u sifirlamak. Kernel, limit 0 iken hicbir dump
  # uretmez (pipe pattern'leri de dahil), boylece core_pattern'in degeri
  # onemsiz hale gelir. "0:0" soft ve hard limiti birlikte sifirlar; surecler
  # limiti sonradan yukseltemez.
  systemd.coredump.enable = false;
  systemd.settings.Manager.DefaultLimitCORE = "0:0";
}
