{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  networking = {
    hostName = "lanz0";
    nftables.enable = true;
    enableIPv6 = false;

    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      #"1.1.1.1"
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
      ethernet.macAddress = "random";

    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];

    fallbackDns = [
      "9.9.9.10"
    ];
    extraConfig = ''
      MulticastDNS=false
      LLMNR=false
    '';
    dnsovertls = "true";
  };
}
