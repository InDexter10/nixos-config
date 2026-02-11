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

    extraHosts = builtins.readFile "${inputs.steven-black-hosts}/hosts";

    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];

    firewall = {
      enable = true;
      allowPing = false;
      logRefusedConnections = false;
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";

      wifi.macAddress = "random";
      ethernet.macAddress = "random";
    };
  };

  services.fail2ban.enable = true;

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];

    fallbackDns = [
      "9.9.9.10"
      "2620:fe::fe"
    ];
    extraConfig = ''
      MulticastDNS=false
      LLMNR=false
    '';
    dnsovertls = "true";
  };
}
