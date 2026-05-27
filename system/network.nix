{
  pkgs,
  lib,
  inputs,
  ...
}:

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
      wifi.macAddress = "random";
      ethernet.macAddress = "stable";
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];

    fallbackDns = [
      "194.242.2.4#base.dns.mullvad.net"
    ];

    extraConfig = ''
      MulticastDNS=false
      LLMNR=false
    '';
    dnsovertls = "true";
  };
}
