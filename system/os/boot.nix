{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;

    # /tmp bellekte: disk sifresiz, oraya tarayici ara dosyalari ve
    # portalin uygulamalara verdigi belge kopyalari duser. tmpfs ayrica
    # nosuid+nodev getirir. cleanOnBoot gereksiz - her boot'ta bos baglanir.
    # BAGLI: nix-daemon'in TMPDIR'i os/nix.nix'te /var/tmp'ye alindi.
    tmp.useTmpfs = true;

    consoleLogLevel = 3;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;

        # init=/bin/sh ile parolasiz root shell alinmasini engeller.
        # security.protectKernelImage bunu YAPMIYOR (nixpkgs kaynagi
        # kontrol edildi) - bu satir gerekli.
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    # lockKernelModules aktif: boot'ta yuklenmemis hicbir modul sonradan
    # yuklenemez. Eksik cikan bir modul buraya eklenip REBOOT edilmeli.
    kernelModules = [
      "usb_storage"
      "uas"
      "sd_mod"

      # Tasinabilir disk dosya sistemleri. vfat kernel tarafindan zaten
      # yukleniyor; bu ikisi yuklenmiyor.
      "exfat"
      "ntfs3"

      # Wi-Fi. af_packet olmadan wpa_supplicant arayuzu tutamaz ve ag
      # listesi bos kalir (2026-08-29'daki ariza buydu). ccm + aes
      # WPA2/CCMP icin iliskilendirme aninda gerekir.
      # WPA3/PMF bir aga baglanilamazsa eksik olan "cmac" olabilir.
      "af_packet"
      "ccm"
      "aes"
    ];

    # Kilit zaten sonradan yuklemeyi engelliyor; liste bu yuzden kisa
    # tutuldu, yalnizca BOOT SIRASINDA otomatik yuklenebilecekleri hedefler.
    blacklistedKernelModules = [
      "dccp"
      "sctp"
      "rds"
      "tipc"

      "firewire-core"
      "thunderbolt"
      "floppy"
      "bluetooth"
      "btusb"

      # Makinede fiziksel DVD yazici VAR (ata1) ama kullanilmiyor. "cdrom"
      # tek basina etkisizdi: blacklist bagimlilik olarak yuklemeyi
      # engellemez, cdrom'u iceri sokan udev'in yukledigi sr_mod'dur.
      # Ikisi birlikte /dev/sr0'i kaldirir.
      "sr_mod"
      "cdrom"

      # Sanallastirma kullanilmiyor.
      "kvm"
      "kvm-intel"

      # msr: userspace'ten ham CPU register erisimi. joydev: oyun kolu.
      # thermald msr'siz sifir uyariyla calisiyor (dogrulandi).
      "msr"
      "joydev"
    ];

    kernelParams = [
      "quiet"
      "udev.log_priority=3"

      "init_on_alloc=1"
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      # init_on_free bilerek kapali: N4000'de %1-3 performans bedeli.

      # DIKKAT: asagidaki uc parametre BU MAKINEDE ETKISIZ. Olculdu
      # (2026-08-31): DMAR birimi hic baslatilmiyor, iommu grubu sifir,
      # i915'in iommu_group bagi yok. Gemini Lake'te VT-d yok ya da
      # firmware'de kapali. Silinmediler cunku BIOS'ta VT-d acilirsa
      # kendiliginden devreye girerler ve donanim yokken bedelleri sifir.
      #   Dogrulama: ls /sys/kernel/iommu_groups/   (bos ise etkisiz)
      "intel_iommu=on"
      "iommu.strict=1"
      "iommu.passthrough=0"

      # Bu CALISIYOR ve VT-d'den bagimsizdir: EFI stub, boot sirasinda PCI
      # bridge bus mastering'ini kapatir.
      "efi=disable_early_pci_dma"

      "vsyscall=none"
      "debugfs=off"

      # networking.enableIPv6 = false yalnizca sysctl ayarlar, bu
      # parametreyi eklemez - ikisi de gerekli.
      "ipv6.disable=1"

      # lockdown=confidentiality EKLENMEDI: bu kernelde
      # CONFIG_SECURITY_LOCKDOWN_LSM derlenmemis, parametre sessizce yok
      # sayilirdi (sahte guvenlik). mitigations=* / nosmt de eklenmedi:
      # N4000'de SMT yok ve lscpu aciklarin cogunu "Not affected" diyor.
    ];

    kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";
      "kernel.sysrq" = 0;

      # 2 = yalnizca root attach edebilir. YAN ETKI: kendi sureclerini bile
      # gdb/strace/perf ile inceleyemezsin. Hata ayiklama gerekirse 1 yap.
      # 3 GERI DONUSSUZDUR.
      "kernel.yama.ptrace_scope" = 2;

      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;

      "kernel.io_uring_disabled" = 2;
      "kernel.perf_event_paranoid" = 3;
      "vm.unprivileged_userfaultfd" = 0;

      # flatpak/bwrap ve nix sandbox user namespace ister; 0 yapmak sistemi
      # calisamaz hale getirir.
      "user.max_user_namespaces" = 500;

      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;

      "dev.tty.ldisc_autoload" = 0;

      # net.ipv4.* sysctl'leri os/network.nix icinde.
    };

    extraModprobeConfig = ''
      install dccp ${pkgs.coreutils}/bin/false
      install sctp ${pkgs.coreutils}/bin/false
      install rds ${pkgs.coreutils}/bin/false
      install tipc ${pkgs.coreutils}/bin/false

      # blacklist yalnizca ALIAS uzerinden otomatik yuklemeyi engeller;
      # acik "modprobe msr" cagrisini engellemez. Bu satir kesin blokler.
      install msr ${pkgs.coreutils}/bin/false

      options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
      options iwlmvm power_scheme=1
    '';
  };

  # nohibernate + kernel.kexec_load_disabled=1
  security.protectKernelImage = true;

  # udev settle sonrasi modules_disabled=1. Calisirken geri alinamaz.
  security.lockKernelModules = true;

  # Core dump cokmus surecin tum bellegini diske yazar; disk sifresiz.
  # systemd.coredump.enable=false TEK BASINA YETMEZ - nixpkgs belgesi
  # "core dumps appear in the current directory of the crashing process"
  # diyor, yani durum kotulesir. RLIMIT_CORE=0 ise kernel'e hicbir dump
  # urettirmez ve surecler limiti sonradan yukseltemez.
  systemd.coredump.enable = false;
  systemd.settings.Manager.DefaultLimitCORE = "0:0";
}
