{ ... }:

# Yetki modeli: global blok VARSAYILAN OLARAK REDDEDER. Bir uygulama yalnizca
# kendi blogunda acikca geri verilen izni alir. Ozgullugu yuksek olan kazanir:
# per-app > global > manifest. Manifest'in istedigi bir izin burada
# reddedilmemisse SESSIZCE GECERLI KALIR - Firefox'un acilmama hatasi buydu.
#
# Reddedilenlerin her biri, bu sistemde karsiliginin olmadigi dogrulanarak
# secildi; "belki lazim olur" diye birakilan yok.

{
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    update.onActivation = false;
    update.auto.enable = false;

    # NOT: yalnizca uygulamalari izler. Tema uzantilari "unmanaged"
    # sayilmadigi icin elle silinmeleri gerekebilir.
    uninstallUnmanaged = true;

    packages = [
      # Flatpak sandbox'i host GTK temasini goremez; tema bir Flatpak
      # UZANTISI olarak kuruluysa kullanabilir. Ad, palette.nix'teki
      # gtkTheme ile ayni olmali.
      "org.gtk.Gtk3theme.adw-gtk3-dark"

      "org.videolan.VLC"
      "org.mozilla.firefox"
      "io.gitlab.librewolf-community"
      "org.kde.okular"
      "org.kde.gwenview"
      "com.github.jeromerobert.pdfarranger"
    ];

    overrides = {
      global = {
        Context = {
          sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
            "!pulseaudio"
            "!ssh-auth"
            "!pcsc"
            "!cups"
            "!gpg-agent"
            "!session-bus"
            "!system-bus"
          ];

          filesystems = [
            # ── Tema koprusu ──
            # DIZIN degil DOSYA izni veriliyor: home-manager bu dizinlerin
            # icine /nix/store'a giden SEMBOLIK BAG koyar. flatpak bir dizini
            # baglarken icindeki baglar sandbox'ta kirik kalir; tek bir DOSYA
            # baglarken ise yolu host tarafinda cozup store dosyasini
            # dogrudan bind eder. (kdeglobals zaten bu yuzden calisiyordu.)
            #
            # Iki dizin izni ayrica REDDEDILIYOR: Firefox manifest'i
            # "xdg-config/gtk-3.0:ro" istiyor ve reddedilmezse flatpak once o
            # dizini salt-okunur baglayip dosya bind'ini imkansiz kiliyor -
            # uygulama bwrap hatasiyla hic acilmiyor.
            "!xdg-config/gtk-3.0"
            "!xdg-config/gtk-4.0"
            "xdg-config/gtk-3.0/settings.ini:ro"
            "xdg-config/gtk-3.0/gtk.css:ro"
            "xdg-config/gtk-4.0/settings.ini:ro"
            "xdg-config/gtk-4.0/gtk.css:ro"

            # Ayni koprunun Qt/KDE ucu (theme/qt.nix). Okular, gwenview ve
            # VLC manifestleri bunu zaten istiyor ve global blokta
            # reddedilmedigi icin calisiyordu - yani tema upstream'in
            # kararina asiliydi. Acikca verilerek bu depoya baglaniyor.
            "xdg-config/kdeglobals:ro"

            "!host"
            "!home"
            "!host-os"
            "!host-etc"
            "!xdg-download"
            "!xdg-documents"
            "!xdg-desktop"
            "!xdg-pictures"
            "!xdg-music"
            "!xdg-videos"
            "!xdg-public-share"
            "!xdg-templates"

            "!xdg-run/gvfs" # VLC istiyor; gvfs kurulu degil
            "!xdg-run/speech-dispatcher" # tarayicilar istiyor; kurulu degil

            # gwenview istiyor. Bu dizin, HERHANGI bir uygulamada onizlenen
            # tum dosyalarin kucuk goruntusunu tutar - dosya sistemini
            # gostermeden dosya sistemini gostermek demek. Reddedilince
            # gwenview kendi onbellegini ~/.var/app icinde uretir.
            "!xdg-cache/thumbnails"

            # gwenview istiyor. Icerigi "silinmis ama duran her dosya".
            # Bedeli: "cope tasi" eylemi calismaz.
            "!xdg-data/Trash"
          ];

          devices = [
            "!all"
            "!dri"
            "!input"
            "!usb"
            "!kvm"
            "!shm"
          ];

          shared = [
            "!network"
            # Alti uygulamanin altisi da istiyor ama tek gercek kullanim alani
            # X11 MIT-SHM; x11 kapali oldugu icin karsiligi yok.
            "!ipc"
          ];

          features = [
            "!devel"
            "!bluetooth"
            "!canbus"
            "!multiarch" # 32-bit calisma zamani (Steam/Wine)
          ];
        };

        # Tum yol zaten kapali (!session-bus); asagidakiler manifest'lerin
        # ACIKCA istedigi ve bu yuzden acilmis olan isimler.
        "Session Bus Policy" = {
          # Sandbox'tan host'ta komut calistirma; kacis yolu.
          "org.freedesktop.Flatpak" = "none";

          # VLC istiyor: kayitli TUM parolalar. Tek kullanimi ag akislarinin
          # kimlik bilgileri ve ag zaten kapali. En agir gereksiz izin.
          "org.freedesktop.secrets" = "none";
          "org.kde.kwalletd5" = "none";
          "org.kde.kwalletd" = "none";

          "org.gtk.vfs.*" = "none"; # gvfs kurulu degil
          "org.freedesktop.FileManager1" = "none"; # dosya yoneticisi yok
          "org.a11y.Bus" = "none"; # ekran okuyucu gerekirse geri acilmali

          # KDE global menu / kded bildirimleri; labwc'de ikisi de yok.
          "com.canonical.AppMenu.Registrar" = "none";
          "org.kde.KGlobalSettings" = "none";
          "org.kde.kconfig.notify" = "none";

          # Oynatma sirasinda kilidi erteleme. swayidle bu arayuzleri
          # UYGULAMIYOR; calisan karsiligi waybar'daki idle_inhibitor.
          "org.freedesktop.ScreenSaver" = "none";
          "org.freedesktop.PowerManagement" = "none";
          "org.freedesktop.login1" = "none"; # okular yanlis yola yazmis

          # VLC istiyor: BASKA oynaticilari kumanda etmek. VLC'nin kendi
          # adini sahiplenmesi bundan ayridir ve dokunulmadi (waybar tepsisi
          # onu kullanir).
          "org.mpris.MediaPlayer2.Player" = "none";
        };

        # Tarayicilarin tek kullanimi captive-portal tespiti; karsiliginda
        # kayitli tum baglantilari, SSID'leri ve donanim adreslerini
        # sayabiliyorlar. Kendi tespitlerine duserler.
        "System Bus Policy" = {
          "org.freedesktop.NetworkManager" = "none";
        };

        # Qt uygulamalarinin KDE platform temasini yuklemesini saglar; o tema
        # kdeglobals'i okuyan tek bilesendir. Ayrica host'tan sizabilecek
        # yanlis bir degeri bastirir. Qt olmayanlar degiskeni yok sayar.
        Environment.QT_QPA_PLATFORMTHEME = "kde";
      };

      # Dosyalar yalnizca portal uzerinden gelir; bunun bedeli "klasordeki
      # sonraki videoya gec"in calismamasidir (portal tek dosyanin fd'sini
      # verir). Klasor gezinmesi istenirse: "xdg-videos:ro".
      #
      # pulseaudio ses cikisi icin zorunlu ve Flatpak'te cikis/giris ayrimi
      # yok - bu soket MIKROFONU da acar. Daha dar bir secenek mevcut degil.
      "org.videolan.VLC".Context = {
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
      };

      # xdg-download:rw bilincli tek istisna: varlik sebebi zaten tarayicidan
      # dosya almak olan tek dizin. Kaldirilirsa indirmeler ~/.var/app icine
      # duser (daha izole ama gozden kaybolur).
      "org.mozilla.firefox".Context = {
        shared = [ "network" ];
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download:rw" ];
      };

      "io.gitlab.librewolf-community".Context = {
        shared = [ "network" ];
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download:rw" ];
      };

      # okular / gwenview / pdfarranger icin blok YOK: ag, ses, dri ve dosya
      # sistemi olmadan, yalnizca portalin verdigi fd ile calisirlar.
      # gwenview'de bunun bedeli klasor gezinmesidir.
    };
  };
}
