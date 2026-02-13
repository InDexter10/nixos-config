{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;

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
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "firewire-core"
      "floppy"
      "sr_mod"
      "cdrom"
      "thunderbolt"
    ];

    kernelParams = [
      "log_level=3"
      "quiet"
      "udev.log_priority=3"
      "init_on_alloc=1"
      "init_on_free=1"
      #"slab_nomerge"
      "page_alloc.shuffle=1"

      "intel_iommu=on"
      "iommu=pt"

      "sysrq_always_enabled=0"
      "lockdown=integrit" # confidentiality

      #"lsm=capability,landlock,lockdown,yama,integrity,apparmor,bpf"
    ];

  };

  systemd.coredump.enable = false;
  security.protectKernelImage = true;

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;

    "kernel.yama.ptrace_scope" = 2;

    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;

    "net.core.bpf_jit_harden" = 2;

    "kernel.unprivileged_userns_clone" = 1;

    "dev.tty.ldisc_autoload" = 0;

    "user.max_user_namespaces" = 1000;
  };

}
