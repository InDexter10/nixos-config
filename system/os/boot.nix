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
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    blacklistedKernelModules = [
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "firewire-core"
      "thunderbolt"
      "floppy"
      "cdrom"
      "bluetooth"
      "btusb"
    ];

    kernelParams = [
      "quiet"
      "udev.log_priority=3"

      "init_on_alloc=1"
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      "intel_iommu=on"

      "vsyscall=none"
      "debugfs=off"

      "ipv6.disable=1"
    ];

    kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";

      "kernel.sysrq" = 0;

      "kernel.yama.ptrace_scope" = 2;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.io_uring_disabled" = 2;
      "kernel.perf_event_paranoid" = 3;
      "vm.unprivileged_userfaultfd" = 0;

      "user.max_user_namespaces" = 500;

      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;

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

      "net.core.bpf_jit_harden" = 2;
      "dev.tty.ldisc_autoload" = 0;
    };

    extraModprobeConfig = ''
      install dccp /bin/false
      install sctp /bin/false
      install rds /bin/false
      install tipc /bin/false
      options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
      options iwlmvm power_scheme=1
    '';
  };

  security.protectKernelImage = true;
  #security.lockKernelModules = false;

  #systemd.coredump.enable = false;
}
