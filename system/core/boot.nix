{ pkgs, ... }:

{
  boot = {
    # ---- Kernel ----
    kernelPackages = pkgs.linuxPackages_latest; # 7.0.x mainline
    initrd.systemd.enable = true; # modern systemd initrd
    tmp.cleanOnBoot = true; # deterministik /tmp

    # Sessiz boot: loglevel'i NixOS'un seçeneğinden ayarla (manuel
    # "loglevel=" kernelParam YERİNE → tek kaynak, "log_level" yazım hatası yok).
    consoleLogLevel = 3;

    # ---- Bootloader ----
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4; # generation menüsünü sınırla
        editor = false; # boot anında cmdline düzenlemeyi kapat
      };
      efi.canTouchEfiVariables = true; # rebuild'in boot entry güncellemesi için
      timeout = 4;
    };

    blacklistedKernelModules = [
      # Nadir / istismara açık ağ protokolleri
      "dccp"
      "sctp"
      "rds"
      "tipc"
      # DMA / fiziksel erişim yüzeyleri
      "firewire-core" # firewire-ohci/sbp2 buna bağımlı → onlar da yüklenmez
      "thunderbolt" # TB dock / eGPU / bazı USB4 kullanıyorsan KALDIR
      "floppy"
      "cdrom"
      "bluetooth"
      "btusb"
    ];

    # ---- Kernel komut satırı ----
    kernelParams = [
      "quiet"
      "udev.log_priority=3"

      # Bellek sertleştirme
      "init_on_alloc=1"
      "init_on_free=1"
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      "intel_iommu=on"
      "amd_iommu=on"
      "iommu=pt"

      # Eski / zayıf yüzeyler
      "vsyscall=none"
      "debugfs=off"

      "ipv6.disable=1"

    ];

    # ---- sysctl sertleştirme ----
    kernel.sysctl = {
      # Kernel bilgi sızıntısı
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";

      # SysRq kapalı
      "kernel.sysrq" = 0;

      # Process güvenliği (yama LSM aktif → ptrace_scope çalışır)
      "kernel.yama.ptrace_scope" = 2;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.perf_event_paranoid" = 3; # mainline 2'yi tavanlar; zararsız
      "vm.unprivileged_userfaultfd" = 0;

      "user.max_user_namespaces" = 500;

      # Filesystem
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;

      # Ağ — IPv4 (IPv6 kapalı olduğu için ipv6.* karşılıkları gereksiz)
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.rp_filter" = 1; # WireGuard/asimetrik routing varsa 2 düşün
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;

      # BPF JIT ve tty
      "net.core.bpf_jit_harden" = 2;
      "dev.tty.ldisc_autoload" = 0;
    };
  };

  #   security.lsm = [ "integrity" ];

  security.protectKernelImage = true;

  security.lockKernelModules = false;

  systemd.coredump.enable = false;
}
