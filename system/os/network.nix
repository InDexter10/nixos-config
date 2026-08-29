{ ... }:

{
  networking = {
    hostName = "msi";
    nftables.enable = true;
    enableIPv6 = false;

    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    firewall = {
      enable = true;
      allowPing = false;
      logRefusedConnections = true;
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = false;
      wifi.macAddress = "stable";
      ethernet.macAddress = "stable";
      connectionConfig = {
        "ipv4.ignore-auto-dns" = true;
        "ipv4.dhcp-send-hostname" = false;
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = true;
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [ "194.242.2.4#base.dns.mullvad.net" ];

      LLMNR = false;
      MulticastDNS = false;
    };
  };
}
