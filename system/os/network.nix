{ lib, ... }:

{
  networking = {
    hostName = "msi";
    nftables.enable = true;
    enableIPv6 = false;

    # NetworkManager modulu ModemManager'i mkDefault ile aciyor; WWAN yok.
    modemmanager.enable = false;

    # resolved'in GLOBAL DNS'i olur. "#dns.quad9.net" soneki DoT sertifika
    # dogrulamasi icin sart, sussuz birakilirsa TLS dogrulamasi anlamsizlasir.
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    firewall = {
      enable = true;
      allowPing = false;

      # nftables backend'inde forward zinciri varsayilan olarak
      # filtrelenmez. Su an container yok; ileride eklenirse kapali gelsin.
      filterForward = true;

      # Log onlemez, gorunurluk verir: "denendi mi?" sorusunu cevaplar.
      # NAT arkasinda inbound gurultu yok, hacim ihmal edilebilir.
      # DIKKAT: uretilen kurallarda limit rate YOK. Halka acik/kalabalik bir
      # aga baglanilirsa hacim gozden gecirilmeli.
      logRefusedConnections = true; # TCP SYN - port taramasi
      logRefusedPackets = true; # UDP/diger; logRefusedUnicastsOnly
      # varsayilani true oldugu icin broadcast/multicast haric
      logReversePathDrops = true; # kaynak sahteciligi / ARP spoof sinyali
    };

    networkmanager = {
      enable = true;

      # NM'in DHCP'den ogrendigi DNS'i resolved'a bildirmesini engeller.
      # mkForce ZORUNLU: resolved modulu bunu mkDefault'suz atiyor.
      #
      # Yan etki: modemin verdigi yerel isimler ("fritz.box") cozulmez.
      # VPN kullanilmaya baslanirsa bu satir gozden gecirilmeli.
      #
      # connectionConfig."ipv4.ignore-auto-dns" AYNI ISI YAPMIYOR - NM onu
      # [connection] varsayilani olarak kabul etmiyor (bu makinede olculdu).
      dns = lib.mkForce "none";

      # dns="none" TEK BASINA YETMIYOR: [main] systemd-resolved anahtari
      # baglantinin DNS'ini D-Bus uzerinden resolved'a gonderir ve
      # VARSAYILANI true'dur. Kapatilmazsa modemin DNS'i link'e kurulur ve
      # koruma yalnizca DNSOverTLS'in duz sorguyu reddetmesine asili kalir.
      settings.main.systemd-resolved = false;

      wifi.powersave = false;

      # "stable": donanim MAC'ini gizler, ayni ag icin sabit kalir.
      # "random" daha siki ama captive portal / MAC filtreli aglarda sorun.
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
      # Strict DoT. Bedeli: 853/tcp'nin kapali oldugu bir agda (captive
      # portal) DNS hic calismaz. Gecici cikis:
      #   sudo resolvectl dnsovertls wlo1 no
      DNSOverTLS = true;

      # Imzasiz alan adlari normal calisir; yalnizca imzasi bozuk olanlar
      # acilmaz. Teshis: resolvectl query --validate=no <alanadi>
      DNSSEC = true;

      Domains = [ "~." ];

      # Bilerek bos: DNS= dolu oldugu icin zaten kullanilmazdi, ama
      # yapilandirma bozulursa sorgularin baska saglayiciya kaymasini
      # kesin olarak engeller.
      FallbackDNS = [ ];

      LLMNR = false;
      MulticastDNS = false;
    };
  };

  # Duz NTP kimligi dogrulanmamistir; saat manipulasyonu TLS sertifika
  # kontrolunu, dolayisiyla DoT'u bozabilir. chrony modulu timesyncd'yi
  # kendisi kapatir.
  #
  # DIKKAT - bagimlilik dongusu: DoT dogru saat ister, chrony NTS ise DNS.
  # RTC saati tuttugu surece sorun cikmaz; CMOS pili biterse ikisi de coker.
  # Kurtarma (root):
  #   timedatectl set-ntp false
  #   timedatectl set-time "YYYY-MM-DD HH:MM:SS"
  #   systemctl restart chronyd
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com"
      "nts.netnod.se"
      "ptbtime1.ptb.de"
    ];
  };

  # Ag davranisi tek yerden okunabilsin diye boot.nix'te degil burada.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;

    # TCP timestamp'leri uptime'i ve NAT arkasindaki host sayisini sizdirir.
    "net.ipv4.tcp_timestamps" = 0;

    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # nftables tarafinda checkReversePath zaten aktif; bu ikinci katman.
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

    # Yerel agda bilgi sizintisini azaltir.
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_announce" = 2;

    # log_martians bilerek ayarlanmadi: tek kullanicili masaustunde
    # surekli log uretir, karsiligi yok.
  };
}
