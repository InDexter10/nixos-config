{ lib, ... }:

{
  networking = {
    hostName = "msi";
    nftables.enable = true;
    enableIPv6 = false;

    # WWAN/3G modem yok. NetworkManager modulu ModemManager'i mkDefault ile
    # aciyor; udev uzerinden seri portlari ve USB cihazlari prob ettigi icin
    # karsiligi olmayan bir saldiri yuzeyi (kural 3 ve 12).
    modemmanager.enable = false;

    # systemd-resolved'in GLOBAL DNS'i olarak kullanilir
    # (services.resolved.settings.Resolve.DNS varsayilani = networking.nameservers).
    # "#dns.quad9.net" soneki DoT sertifika dogrulamasi icin gereken sunucu adidir,
    # sussuz birakilirsa TLS dogrulamasi anlamsizlasir.
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    firewall = {
      enable = true;
      allowPing = false;

      # nftables backend'inde forward zinciri varsayilan olarak filtrelenmez.
      # Su an container/VM yok, yani etkisi gorunmez; ileride biri eklenirse
      # varsayilan olarak kapali olsun diye aciyoruz.
      filterForward = true;

      # logRefusedConnections BILEREK ayarlanmadi (varsayilani false).
      # Default-deny bir guvenlik duvarinda bu loglar tek kullanicili masaustunde
      # okunmuyor, sadece dmesg'i dolduruyor (kural 11).
    };

    networkmanager = {
      enable = true;

      # --- DNS zorlamasi ---
      # NetworkManager'in DHCP'den ogrendigi DNS sunucusunu resolved'a
      # bildirmesini tamamen engeller. Boylece tek DNS yolu global Quad9 + DoT
      # olur ve agin verdigi cozumleyici hicbir sekilde devreye giremez.
      #
      # mkForce ZORUNLU: services.resolved modulu bu secenegi mkDefault olmadan
      # "systemd-resolved" olarak atiyor, mkForce olmadan build catisir.
      #
      # NOT: Ayni is icin denenen connectionConfig."ipv4.ignore-auto-dns"
      # CALISMIYOR - NetworkManager bu ozelligi [connection] varsayilani olarak
      # kabul etmiyor, bu makinede olculdu (profil "ignore-auto-dns: no"
      # kaliyor ve modemin DNS'i link'e yaziliyordu). O yuzden kullanilmiyor.
      #
      # Yan etkiler:
      #  - Modemin verdigi yerel isimler (ornegin "fritz.box") cozulmez, IP gerekir.
      #  - VPN kullanilmaya baslanirsa VPN'in DNS'i de gecmeyecegi icin bu satirin
      #    gozden gecirilmesi gerekir.
      dns = lib.mkForce "none";

      # dns = "none" TEK BASINA YETMIYOR. NetworkManager.conf'un [main] bolumundeki
      # "systemd-resolved" anahtari, baglantinin DNS yapilandirmasini resolved'a
      # D-Bus uzerinden gondermeyi kontrol eder ve VARSAYILANI true'dur; man
      # sayfasinin deyimiyle "complementary to the dns setting".
      #
      # Kapatilmazsa modemin DHCP ile verdigi DNS link'e kurulur
      # (journal: "wlo1: Bus client set DNS server list to: 192.168.43.1").
      # Bu haliyle sorgular fiilen modeme gitmiyordu, ama SADECE modem DoT
      # konusmadigi ve DNSOverTLS=true duz sorguyu reddettigi icin. Yani koruma
      # tek bir ayara asili kaliyordu; bu satir tasarimi kendi ayaklari uzerine
      # oturtur.
      settings.main.systemd-resolved = false;

      wifi.powersave = false;

      # "stable": donanim MAC'ini gizler, ayni ag icin sabit kalir.
      # Daha sikisi "random" (her baglantida yeni MAC) ama captive portal ve
      # MAC filtreli aglarda zahmet cikarir; ev agi + hotspot senaryosunda
      # gereksiz bulundu.
      wifi.macAddress = "stable";
      ethernet.macAddress = "stable";

      connectionConfig = {
        # Hostname'in DHCP istegiyle aga sizmasini engeller.
        "ipv4.dhcp-send-hostname" = false;

        # IPv6 kernel duzeyinde zaten kapali; NM'in bosuna deneyip hata
        # loglamasini onler.
        "ipv6.method" = "disabled";
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      # Strict DoT. Bilincli bedel: 853/tcp'nin kapali oldugu bir agda
      # (bazi captive portal'lar) DNS hic calismaz.
      DNSOverTLS = true;

      # Yerel DNSSEC dogrulamasi.
      #  - Imzasiz alan adlari (internetin cogunlugu) normal calisir.
      #  - Sadece imzasi bozuk / suresi gecmis alan adlari acilmaz.
      # Kazanc: Quad9 ele gecirilse veya yalan soylese fark edilir.
      # Bir alan adi acilmazsa teshis:
      #   resolvectl query --validate=no <alanadi>
      DNSSEC = true;

      # Tum sorgular global scope'a gider; link bazli DNS'e dusmez.
      Domains = [ "~." ];

      # BILEREK BOS. DNS= dolu oldugu icin systemd-resolved FallbackDNS'i zaten
      # kullanmazdi, ama yapilandirma bir gun bozulursa sorgularin baska bir
      # saglayiciya kaymasini kesin olarak engeller (kural 2).
      FallbackDNS = [ ];

      LLMNR = false;
      MulticastDNS = false;
    };
  };

  # --- Saat senkronizasyonu ---
  # Duz NTP kimligi dogrulanmamis bir protokoldur. Saat manipulasyonu TLS
  # sertifika gecerlilik kontrolunu (dolayisiyla DoT'u) bozabilecegi icin,
  # DNS tarafi bu kadar sikilastirilmisken saatin acikta kalmasi tutarsizlik
  # olurdu (kural 6). chrony + NTS bu bosluğu kapatir.
  # chrony modulu systemd-timesyncd'yi mkForce ile kendisi kapatir.
  #
  # DIKKAT - bagimlilik dongusu: DoT sertifika dogrulamasi ~dogru saat ister,
  # chrony NTS ise DNS ister. Normalde RTC saati tuttugu icin sorun cikmaz.
  # CMOS pili biterse ikisi de coker. Kurtarma (root):
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

  # --- Ag ile ilgili kernel parametreleri ---
  # Bunlar bilincli olarak boot.nix'te degil burada tutuluyor: modul sinirlari
  # net olsun, ag davranisi tek yerden okunabilsin (kural 6).
  boot.kernel.sysctl = {
    # SYN flood korumasi
    "net.ipv4.tcp_syncookies" = 1;
    # TIME-WAIT assassination (RFC 1337) korumasi
    "net.ipv4.tcp_rfc1337" = 1;

    # TCP timestamp'leri sistem uptime'ini ve NAT arkasindaki host sayisini
    # disariya sizdirir; klasik bir parmak izi vektorudur (kural 2).
    "net.ipv4.tcp_timestamps" = 0;

    # ICMP
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # Reverse path filtresi. nftables tarafinda checkReversePath zaten aktif;
    # bu kernel duzeyinde ikinci katman.
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # ICMP redirect kabul etme / gonderme
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # Kaynak yonlendirmeli paketleri reddet
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;

    # ARP: sadece paketin geldigi arayuze ait IP icin cevap ver, kaynak adresi
    # gereksiz yere duyurma. Yerel agda bilgi sizintisini azaltir (kural 2).
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_announce" = 2;

    # log_martians BILEREK ayarlanmadi (kernel varsayilani 0). Tek kullanicili
    # masaustunde surekli log uretir, karsiligi yok (kural 11).
  };
}
