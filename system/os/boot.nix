{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;

    tmp.useTmpfs = true;

    # ntfs3 yerine FUSE tabanli ntfs-3g. Bozuk/kotu niyetli bir imaj
    # cekirdek yerine yetkisiz bir kullanici surecinde ayristirilir.
    supportedFilesystems.ntfs = true;

    consoleLogLevel = 3;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;

        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    kernelModules = [
      "usb_storage"
      "uas"
      "sd_mod"

      "exfat"

      "af_packet"
      "ccm"
      "aes"
      "nf_log_syslog"
    ];

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

      "sr_mod"
      "cdrom"

      "kvm"
      "kvm-intel"

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

      "intel_iommu=on"
      "iommu.strict=1"
      "iommu.passthrough=0"

      "efi=disable_early_pci_dma"

      "vsyscall=none"
      "debugfs=off"

      "ipv6.disable=1"

      # 32-bit syscall ABI'sini kapatir. Kullanan yok: Steam/Wine yok,
      # flatpak global override'inda "!multiarch".
      "ia32_emulation=0"
    ];

    kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";
      "kernel.sysrq" = 0;

      "kernel.yama.ptrace_scope" = 2;

      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;

      "kernel.io_uring_disabled" = 2;
      "kernel.perf_event_paranoid" = 3;
      "vm.unprivileged_userfaultfd" = 0;

      "user.max_user_namespaces" = 500;

      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;

      "dev.tty.ldisc_autoload" = 0;
    };

    extraModprobeConfig = ''
      install dccp ${pkgs.coreutils}/bin/false
      install sctp ${pkgs.coreutils}/bin/false
      install rds ${pkgs.coreutils}/bin/false
      install tipc ${pkgs.coreutils}/bin/false

      # blacklist yalnizca alias uzerinden otomatik yuklemeyi engeller,
      # acik "modprobe msr" cagrisini engellemez.
      install msr ${pkgs.coreutils}/bin/false

      options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
      options iwlmvm power_scheme=1
    '';
  };

  security.protectKernelImage = true;

  security.lockKernelModules = true;

  systemd.coredump.enable = false;
  systemd.settings.Manager.DefaultLimitCORE = "0:0";
}
