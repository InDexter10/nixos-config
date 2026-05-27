{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.systemd.enable = true;
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    blacklistedKernelModules = [
      # Az kullanılan ağ protokolleri, CVE geçmişi var
      "dccp"
      "sctp"
      "rds"
      "tipc"
      # Eski/yok donanımlar
      "firewire-core"
      "floppy"
      "thunderbolt"
      "sr_mod"
      "cdrom"
    ];

    kernelParams = [
      # Sessiz boot
      "log_level=3"
      "quiet"
      "udev.log_priority=3"

      # Bellek sertleştirme
      "init_on_alloc=1"
      "init_on_free=1"
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      # IOMMU
      "intel_iommu=on"
      "amd_iommu=on"
      "iommu=pt"

      "lsm=landlock,yama,integrity,apparmor,bpf"

      # Eski/zayıf yüzeyler
      "vsyscall=none"
      "debugfs=off"

      "ipv6.disable=1"
    ];
  };

  systemd.coredump.enable = false;

  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
    packages = [ pkgs.apparmor-profiles ];
  };

  security.lockKernelModules = true;
  security.protectKernelImage = true;

  boot.kernel.sysctl = {
    # Kernel bilgi sızıntısı
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.printk" = "3 3 3 3";

    # SysRq
    "kernel.sysrq" = 0;

    # Process güvenliği
    "kernel.yama.ptrace_scope" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.perf_event_paranoid" = 3;
    "vm.unprivileged_userfaultfd" = 0;
    "kernel.kexec_load_disabled" = 1;

    # Sandbox için user namespace açık
    "user.max_user_namespaces" = 500;

    # Filesystem
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.suid_dumpable" = 0;

    # Ağ — IPv4
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
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

    # Ağ — IPv6
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # BPF JIT ve tty
    "net.core.bpf_jit_harden" = 2;
    "dev.tty.ldisc_autoload" = 0;
  };
}
