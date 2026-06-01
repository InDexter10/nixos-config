# ironbar.nix — COSMIC-tarzı, minimal, deterministik bar (home-manager modülü)
#
# Felsefe: safe / stable / reliable / unbloat / deterministic.
# - Flake KULLANMIYORUZ. ironbar master'dan değil, nixpkgs-26.05'e pinlenmiş
#   sürümden gelir. Böylece ironbar'ın "alpha / sürekli breaking change" doğası
#   senin kanal yükseltmene kadar DONDURULUR. Determinizm = kontrol sende.
# - Config ve stil ayrı dosyalar olarak yazılır (xdg.configFile). flake HM
#   modülüne bağımlılık yok; çakışma/tekrar kurulum riski yok (kural 5).
# - Ses/parlaklığın "native kayan slider" hissi BARDAN değil, SwayOSD'den gelir.
#   ironbar'ın volume popup'u tamamlayıcıdır, OSD asıl native yoldur.
#
# Bu dosyayı home.nix içinden import et:
#   imports = [ ./ironbar.nix ];

{ config, pkgs, lib, ... }:

let
  jsonFormat = pkgs.formats.json { };

  # ---------------------------------------------------------------------------
  # ironbar yapılandırması (JSON'a çevrilir). Şema: JakeStanger/ironbar wiki.
  # Tek monitör → top-level start/center/end (monitör adı gerekmez).
  # ---------------------------------------------------------------------------
  ironbarConfig = {
    position = "top";
    height = 34;             # COSMIC üst paneli ~32-36px, ince ve temiz
    anchor_to_edges = true;  # kenardan kenara, tam genişlik (COSMIC üst paneli)

    # --- SOL: taskbar + (workspaces, doğrulanacak) -------------------------
    start = [
      # workspaces: labwc first-class DEĞİL. labwc ext_workspaces_manager_v1
      # destekliyor ama ironbar'ın bu modülünün labwc'de dolup dolmadığını
      # KURARKEN DOĞRULA. Boş kalırsa bu bloğu sil — taskbar zaten yeterli.
      {
        type = "workspaces";
        all_monitors = false;
        sort = "index";
      }

      # launcher = ironbar'ın taskbar'ı. wlr-foreign-toplevel üzerinden çalışır,
      # labwc bunu KESIN destekler. Asıl sol-taraf taşıyıcısı budur.
      {
        type = "launcher";
        show_names = false;   # COSMIC-temiz: sadece ikon
        show_icons = true;
        icon_size = 20;
        reversed = false;
        favorites = [
          # Sık kullandıklarını app_id ile ekle (boş bırakabilirsin):
          # "firefox" "org.kde.okular" "vlc"
        ];
      }

      # sys_info = CPU/RAM/load göstergesi (inline).
      # NOT: Sen "açılır-kapanır popup" istemiştin. ironbar'da bunun temiz yolu
      # `custom` modülüdür ama o, wiki'nin kendi deyimiyle "fiddly" ve alpha.
      # Bu yüzden ilk sürümde sağlam/inline bırakıyorum (COSMIC-minimal: küçük).
      # Tıkla-aç popup versiyonunu, BASE bar çalıştığı teyit edilince ayrı bir
      # adımda inşa edebiliriz (custom + sys_info ironvars: sysinfo.cpu_percent…).
      {
        type = "sys_info";
        format = [
          "CPU {cpu_percent}%"
          "RAM {memory_percent}%"
          "LD {load_average:1}"
        ];
        interval = 5;  # saniye. Sürümünde hata verirse map biçimini dene:
                       # interval = { cpus = 5; memory = 5; load_average = 5; };
      }
    ];

    # --- ORTA: saat + tarih (native takvim popup'u dahili) -----------------
    center = [
      {
        type = "clock";
        # %a=gün, %d=gün-no, %b=ay, %H:%M=saat. Tıklayınca dahili takvim popup açılır.
        format = "%a %d %b   %H:%M";
        format_popup = "%H:%M:%S";
        # Gerçek takvim UYGULAMASI istersen on_click ekle (ironbar takvimi yerine):
        # on_click = "!gnome-calendar";
      }
    ];

    # --- SAĞ: kontrol (ses + parlaklık + tray) -----------------------------
    end = [
      # volume: tıklayınca native popover'da slider + cihaz seçici açılır.
      {
        type = "volume";
        format = "{percentage}%";   # temiz; Nerd Font ikonu istersen "{icon} {percentage}%"
        max_volume = 100;
        # icons = { volume_high = "󰕾"; volume_medium = "󰖀"; volume_low = "󰕿"; muted = "󰝟"; };
      }

      # brightness: GTK4 ironbar'da mevcut bir modül. Alanlarını KURARKEN DOĞRULA;
      # sürümünde yoksa bu bloğu sil — parlaklık zaten SwayOSD ile (aşağıda) çözülür.
      {
        type = "brightness";
      }

      # tray = uygulama göstergeleri (COSMIC üst-sağ köşesi gibi).
      {
        type = "tray";
        icon_size = 18;
      }
    ];
  };
in
{
  # ---------------------------------------------------------------------------
  # 1) Paket: nixpkgs-26.05'ten (PINLENMIŞ). Flake YOK = breaking change donmuş.
  #    KURARKEN DOĞRULA: `ironbar --version` GTK4 sürüm olmalı (native popover için).
  #    Tüm modüller varsayılan olarak derlenir (clock/volume/tray/sys_info/...).
  # ---------------------------------------------------------------------------
  home.packages = [ pkgs.ironbar ];

  # ---------------------------------------------------------------------------
  # 2) Config dosyası → ~/.config/ironbar/config.json (deterministik, Nix'ten üretilir)
  #    DİKKAT (kural 5): ~/.config/ironbar altında başka config.* (corn/toml/yaml)
  #    DOSYASI VARSA SİL — ironbar birden fazla config görürse şaşırır.
  # ---------------------------------------------------------------------------
  xdg.configFile."ironbar/config.json".source =
    jsonFormat.generate "ironbar-config.json" ironbarConfig;

  # ---------------------------------------------------------------------------
  # 3) COSMIC-tarzı stil → ~/.config/ironbar/style.css (CSS hot-reload edilir)
  #    GTK4 CSS subset'i: rgba/border-radius/padding/transition çalışır.
  # ---------------------------------------------------------------------------
  xdg.configFile."ironbar/style.css".text = ''
    /* ---- Genel: temiz sans, orta kalınlık ---- */
    * {
      font-family: "Inter", "Noto Sans", sans-serif;
      font-size: 13px;
      font-weight: 500;
      /* GTK4'te yumuşak geçişler */
      transition: background-color 150ms ease;
    }

    /* ---- Bar gövdesi: koyu, hafif yarı saydam, ince alt çizgi ---- */
    .background {
      background-color: rgba(20, 20, 22, 0.85);
      color: #e6e6e6;
      border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    }

    /* ---- Modül butonları: şeffaf, hover'da hafif pill ---- */
    button {
      background-color: transparent;
      border: none;
      border-radius: 8px;
      padding: 0 8px;
      margin: 4px 3px;
      min-height: 0;
    }
    button:hover {
      background-color: rgba(255, 255, 255, 0.08);
    }

    /* ---- Saat: biraz daha belirgin (orta odak) ---- */
    .clock {
      font-weight: 600;
      letter-spacing: 0.3px;
    }

    /* ---- Workspaces: aktif olan vurgulu ---- */
    .workspaces button.focused,
    .workspaces button:checked {
      background-color: rgba(255, 255, 255, 0.14);
    }
    .workspaces button.urgent {
      background-color: rgba(235, 110, 90, 0.30);
    }

    /* ---- sys_info: gri-soft, dikkat çekmeyen ---- */
    .sys-info {
      color: #b8b8bd;
    }

    /* ---- Tray ikonları biraz nefes alsın ---- */
    .tray button {
      padding: 0 5px;
    }

    /* ---- Popover'lar (saat takvimi, ses slider'ı): kart görünümü ---- */
    .popup {
      background-color: rgba(28, 28, 30, 0.96);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 12px;
      padding: 12px;
      color: #e6e6e6;
    }
    .popup button:hover {
      background-color: rgba(255, 255, 255, 0.10);
    }
  '';

  # ---------------------------------------------------------------------------
  # 4) SwayOSD: ses + parlaklık için NATIVE kayan OSD (GNOME/COSMIC hissi).
  #    Bu, barın volume popup'undan AYRI ve onunla çakışmaz; tuşa basınca
  #    ekranda anlık slider belirir. Asıl "native" deneyim budur.
  #    Server bir kullanıcı servisi olarak çalışır (root/libinput watcher YOK =
  #    daha az saldırı yüzeyi, kural 4'e uygun).
  # ---------------------------------------------------------------------------
  services.swayosd.enable = true;
  # İsteğe bağlı: OSD'yi ekranın altına yakın konumla
  # services.swayosd.topMargin = 0.85;
}
