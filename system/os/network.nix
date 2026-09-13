{ lib, ... }:

{
  networking = {
    hostName = "msi";
    nftables.enable = true;
    enableIPv6 = false;

    modemmanager.enable = false;

    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    firewall = {
      enable = true;
      allowPing = false;

      filterForward = true;

      logRefusedConnections = true;
      logRefusedPackets = true;
      logReversePathDrops = true;
    };

    networkmanager = {
      enable = true;

      dns = lib.mkForce "none";

      settings.main.systemd-resolved = false;

      wifi.powersave = false;

      wifi.macAddress = "stable";
      ethernet.macAddress = "stable";

      connectionConfig = {
        "ipv4.dhcp-send-hostname" = false;
        "ipv6.method" = "disabled";
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = true;

      DNSSEC = true;

      Domains = [ "~." ];

      FallbackDNS = [ ];

      LLMNR = false;
      MulticastDNS = false;
    };
  };

  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com"
      "nts.netnod.se"
      "ptbtime1.ptb.de"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;

    "net.ipv4.tcp_timestamps" = 0;

    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;

    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_announce" = 2;
  };
}
