{ config, pkgs, ... }:

{
  # Ironbar paketini sisteme ekliyoruz
  home.packages = with pkgs; [ ironbar ];

  # Ironbar Konfigürasyonu (TOML Formatı)
  xdg.configFile."ironbar/config.toml".text = ''
    # --- PANEL TEMEL AYARLARI ---
    position = "top"          # Panel ekranın en üstünde yer alacak
    height = 32               # İnce, estetik ve profesyonel bir yükseklik
    anchor_to_edges = true    # Köşelere tam yapışmasını sağlar (kenarlarda boşluk kalmaz)
    icon_theme = "Papirus-Dark" # Sistem ikon teması (sistemindeki karanlık temayı çeker)

    # --- DİZİLİM MİMARİSİ ---
    start = ["workspaces", "focused"]  # Sol taraf: Çalışma alanları ve o an açık/aktif olan pencere
    center = ["clock"]                 # Merkez: Saat ve Tarih
    end = ["cpu", "memory", "brightness", "volume", "network"] # Sağ taraf: Donanım ve Sistem durumları

    # --- 1. ÇALIŞMA ALANLARI (WORKSPACES) ---
    [workspaces]
    type = "workspaces"
    name_map = { "1" = "1", "2" = "2", "3" = "3", "4" = "4" } # İsimleri Romen rakamı (I, II) falan da yapabilirsin

    # --- 2. AKTİF PENCERE (FOCUSED) ---
    [focused]
    type = "focused"
    show_icon = true
    show_title = true
    icon_size = 16
    truncate = "end"        # İsim çok uzunsa panelin yapısını bozmamak için sonuna ... koyar
    max_length = 50         # Maksimum başlık sınırı

    # --- 3. SAAT ---
    [clock]
    type = "clock"
    format = "%d.%m.%Y - %H:%M"

    # --- 4. İŞLEMCİ (CPU) ---
    [cpu]
    type = "sys_info"
    interval = 2            # 2 saniyede bir güncellenir
    format = ["CPU: {cpu_percent}%"]

    # --- 5. RAM (BELLEK) ---
    [memory]
    type = "sys_info"
    interval = 5            # 5 saniyede bir güncellenir
    format = ["RAM: {memory_percent}%"]

    # --- 6. PARLAKLIK ---
    # Ironbar parlaklığı genelde shell betikleriyle çözer (Minimalisttir).
    [brightness]
    type = "script"
    mode = "poll"
    interval = 2
    cmd = "brightnessctl -m | awk -F, '{print \"BRI: \" substr($4, 0, length($4)-1) \"%\"}'"

    # --- 7. SES (VOLUME) ---
    [volume]
    type = "volume"
    format = "VOL: {volume}%"
    max_volume = 100

    # --- 8. AĞ (WIFI) ---
    # O an bağlı olduğun ağın adını (SSID) gösterir. Dil ayarlarına takılmasın diye regex eklendi.
    [network]
    type = "script"
    mode = "poll"
    interval = 5
    cmd = "nmcli -t -f active,ssid dev wifi | grep -E '^(yes|evet)' | cut -d: -f2 | sed 's/^/WIFI: /' || echo 'WIFI: Offline'"
  '';

  # --- IRONBAR GÖRÜNÜM (CSS) KODLARI ---
  xdg.configFile."ironbar/style.css".text = ''
    /* --- SIFIRLAMA (RESETS) --- */
    * {
      font-family: "monospace"; /* Varsa JetBrains Mono kullanır, yoksa standart monospace */
      font-size: 13px;
      border: none;
      border-radius: 0;      /* Yuvarlak köşeleri iptal et, ciddi ve sert bir görünüm kat */
      box-shadow: none;      /* Gölgeleri iptal et, işlemciyi yorma */
    }

    /* --- ANA PANEL (TAM SİYAH) --- */
    window#ironbar {
      background-color: #000000;
      color: #FFFFFF;
      border-bottom: 1px solid #1A1A1A; /* Aşağıyı diğer pencerelerden ayırmak için çok ince/silik sınır */
    }

    /* --- GENEL MODÜL AYARLARI --- */
    .module {
      padding: 0 12px;
      color: #AAAAAA; /* Varsayılan metin gri (göz yormaması için) */
    }

    /* --- ÇALIŞMA ALANLARI (WORKSPACES) --- */
    .workspaces .item {
      padding: 0 10px;
      color: #555555; /* İçinde bulunduğun ama aktif olmayan alanlar çok koyu gri */
      background-color: transparent;
      margin: 0;
    }
    .workspaces .item.focused {
      color: #FFFFFF; /* O an aktif olan alan beyaz */
      font-weight: bold;
      background-color: #111111; /* Aktif alanın arkaplanı çok hafif aydınlanır */
      border-bottom: 2px solid #FFFFFF; /* Altını net bir çizgiyle belirtiriz */
    }

    /* --- AÇIK PENCERE İSMİ --- */
    .focused {
      color: #FFFFFF;
      font-weight: bold;
    }

    /* --- SAAT (MERKEZ) --- */
    .clock {
      color: #FFFFFF;
      font-weight: bold;
      font-size: 14px;
    }

    /* --- SAĞ MODÜLLER (SİSTEM DURUMU) --- */
    /* Vurgulamak istersen bunlara özel renkler (Kırmızı CPU gibi) verebilirsin 
       ama profesyonel olması için monokrom (siyah/beyaz/gri) tutuyoruz. */
    .sys_info, .script, .volume {
      color: #CCCCCC;
    }
  '';
}
