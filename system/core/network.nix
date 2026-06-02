{ ... }:

{
  networking = {
    hostName = "msi";
    nftables.enable = true; # modern firewall backend (iptables değil)
    enableIPv6 = false; # boot.nix'teki ipv6.disable=1 ile tutarlı

    # Quad9, isim-doğrulamalı (strict DoT için SNI eşleştirmesi).
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    firewall = {
      enable = true;
      allowPing = false; # echo-request düşürülür (echo-reply'a dokunmaz)
      logRefusedConnections = true; # nft "refused connection:" log prefix'i
    };

    networkmanager = {
      enable = true;

      dns = "systemd-resolved";

      wifi.powersave = false;

      wifi.macAddress = "random";
      ethernet.macAddress = "random";
      connectionConfig = {
        "ipv4.ignore-auto-dns" = true;
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
