{
  pkgs,
  lib,
  ...
}:

let
  mkLockPrefs =
    prefs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "lockPref(${builtins.toJSON k}, ${builtins.toJSON v});") prefs
    );

  hardenedPrefs = {
    # -- Telemetri / veri raporlama (telemetry.mozilla.org) --
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.coverage.opt-out" = true;
    "toolkit.coverage.endpoint.base" = "";
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "beacon.enabled" = false;

    # -- Shield / Normandy çalışmaları (normandy.cdn.mozilla.net) --
    "app.shield.optoutstudies.enabled" = false;
    "app.normandy.enabled" = false;
    "app.normandy.api_url" = "";

    # -- Çökme raporu gönderimi --
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;

    # -- Bağlantı / captive-portal yoklaması (detectportal.firefox.com) --
    "network.captive-portal-service.enabled" = false;
    "network.connectivity-service.enabled" = false;
    "captivedetect.canonicalURL" = "";

    # -- Prefetch / speculative bağlantı (ağ sızıntısı) --
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "network.predictor.enabled" = false;
    "network.predictor.enable-prefetch" = false;

    # -- DoH/TRR kapalı: sistem resolved + DoT kullanılsın (network.nix ile tutarlı) --
    "network.trr.mode" = 5;

    # -- Push servisi (push.services.mozilla.com) --
    "dom.push.enabled" = false;
    "dom.push.serverURL" = "";

    # -- Konum / bölge ağ sorguları (location.services.mozilla.com) --
    "geo.provider.network.url" = "";
    "geo.provider.use_geoclue" = false;
    "browser.region.network.url" = "";
    "browser.region.update.enabled" = false;

    # -- AMO keşif/öneri trafiği (eklenti GÜNCELLEMESİ değil; o açık kalıyor) --
    "extensions.getAddons.showPane" = false;
    "extensions.getAddons.cache.enabled" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "browser.discovery.enabled" = false;

    # -- Yeni sekme telemetrisi + sponsorlu içerik --
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

    # -- Gizlilik: modern parmak-izi koruması (FPP; tam RFP'den daha az kırıcı) --
    "privacy.fingerprintingProtection" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;

  };

  # ---------------------------------------------------------------------------
  # 1) Politika ile sertleştirilmiş Firefox (wrapFirefox.extraPolicies + extraPrefs)
  # ---------------------------------------------------------------------------
  hardenedFirefox = pkgs.firefox.override {
    extraPrefs = mkLockPrefs hardenedPrefs;

    extraPolicies = {
      # -- Telemetri / arka plan veri toplama --
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableDefaultBrowserAgent = true; # arka plan telemetri ajanı
      DontCheckDefaultBrowser = true; # "varsayılan tarayıcı yap" nag'i yok
      CaptivePortal = false; # captive-portal yoklaması (policy seviyesinde de kapalı)

      # -- Hesap / Sync (accounts.firefox.com) — Bitwarden var, Sync'e gerek yok --
      DisableFirefoxAccounts = true; # Sync istersen bu satırı sil

      # -- Güncelleme: Firefox'u Nix yönetir (uygulama auto-update kapalı). --
      #    NOT: Eklenti güncellemesi (ExtensionUpdate) BİLİNÇLİ olarak açık (güvenlik).
      DisableAppUpdate = true;
      DisableSystemAddonUpdate = true;

      # -- DNS: sistem resolved + DoT kullanılsın; Firefox kendi DoH'unu açıp sistem
      #    çözümleyiciyi ATLAMASIN (network.nix ile tutarlı). --
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };

      # -- DRM (Widevine = Google kapalı kaynak). Korsan/derme stream siteleri düz
      #    HTML5/HLS kullanır → tehdit modeliyle uyumlu kapalı. Netflix/Spotify/DAZN
      #    gibi MEŞRU DRM istersen Enabled = true yap. --
      EncryptedMediaExtensions = {
        Enabled = false;
        Locked = true;
      };

      # -- Parola: Bitwarden EKLENTİSİ kullanılıyor. Aşağıdaki iki satır YALNIZCA
      #    Firefox'un YERLEŞİK parola yöneticisini (about:logins + "kaydedeyim mi?"
      #    çıktısı) kapatır; Bitwarden eklentisine dokunmaz, onunla çakışmaz. --
      OfferToSaveLogins = false;
      DisablePasswordReveal = true;

      # -- Ağ sızıntısı --
      NetworkPrediction = false; # prefetch / speculative DNS

      # -- Yeni sekme: Pocket / sponsorlu / snippet (Mozilla'dan çekilir) kapalı --
      FirefoxHome = {
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        SponsoredTopSites = false;
      };

      # -- İlk çalıştırma / nag / öneri gürültüsü --
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisableSetDesktopBackground = true;
      DisableFeedbackCommands = true;
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
      };

      # -- EKLENTİ ALLOWLIST (default-deny / zero-trust) --
      #    "*" = blocked  → listede olmayan HER eklenti reddedilir, elle kurulamaz.
      #    force_installed → kaldırılamaz/devre dışı bırakılamaz; AMO'dan güvenlik
      #    güncellemesi alır (telemetri değil; bilinçli açık tek Mozilla-temaslı kanal).
      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
          blocked_install_message = "Yalnızca sistemde tanımlı eklentiler kullanılabilir.";
        };
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        # Bitwarden Password Manager
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        # Firefox Multi-Account Containers
        "@testpilot-containers" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 2) bwrap sandbox sarmalayıcı — bin adı "firefox" (PATH'te ham Firefox'u gölgeler)
  # ---------------------------------------------------------------------------
  firefox-sandboxed = pkgs.writeShellScriptBin "firefox" ''
    set -euo pipefail

    # ── İzole, kalıcı kullanıcı verisi (yalnızca bunlar yazılabilir) ──
    PROFILE_HOME="$HOME/.mozilla-sandbox"
    CACHE_HOME="$HOME/.cache/mozilla-sandbox"
    DOWNLOADS="$HOME/Downloads"
    mkdir -p "$PROFILE_HOME/firefox" "$CACHE_HOME" "$DOWNLOADS"

    # ── Runtime dizini + Wayland soketi (labwc'de wayland-0/1 olabilir) ──
    XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    WL_NAME="''${WAYLAND_DISPLAY:-wayland-0}"
    case "$WL_NAME" in
      /*) WL_SRC="$WL_NAME"; WL_DST="$WL_NAME" ;;                      # mutlak yol
      *)  WL_SRC="$XDG_RUNTIME_DIR/$WL_NAME"; WL_DST="$WL_SRC" ;;      # göreli ad
    esac

    args=()

    # ── Namespace izolasyonu ──
    args+=(--unshare-all)        # tüm namespace'ler (user/pid/ipc/uts/cgroup/mount/net)
    args+=(--share-net)          # ...ağ hariç (tarayıcı için zorunlu)
    args+=(--hostname localhost) # gerçek makine adını gizle (UTS ns)
    args+=(--die-with-parent)    # başlatıcı ölünce sandbox da ölsün
    args+=(--new-session)        # TIOCSTI terminal enjeksiyonuna karşı

    # ── Çekirdek sistem (salt-okunur) ──
    args+=(--ro-bind /nix/store /nix/store)   # tüm closure burada; daraltmak pratik değil
    args+=(--proc /proc)                      # taze, izole /proc
    args+=(--dev /dev)                        # minimal /dev (null, urandom, ...)
    args+=(--tmpfs /tmp)                      # izole geçici alan
    args+=(--tmpfs /dev/shm)                  # ZORUNLU: Firefox içerik süreçleri shm kullanır

    # ── GPU: Intel UHD 600 (Gemini Lake, Mesa + VA-API) ──
    args+=(--dev-bind /dev/dri /dev/dri)               # DRM render node
    args+=(--ro-bind /run/opengl-driver /run/opengl-driver)  # Mesa/VA-API sürücü yolu
    args+=(--ro-bind-try /sys/dev/char  /sys/dev/char) # libdrm cihaz numaralandırma
    args+=(--ro-bind-try /sys/devices   /sys/devices)
    args+=(--ro-bind-try /sys/class/drm /sys/class/drm)

    # ── Ağ / isim çözümleme / CA sertifikaları ──
    args+=(--ro-bind-try /etc/resolv.conf  /etc/resolv.conf)   # 127.0.0.53 stub (loopback paylaşımlı)
    args+=(--ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf) # nss-resolve yönlendirmesi
    args+=(--ro-bind-try /etc/hosts        /etc/hosts)
    args+=(--ro-bind-try /etc/ssl          /etc/ssl)
    args+=(--ro-bind-try /etc/static       /etc/static)        # NixOS ssl/font symlink hedefleri
    args+=(--ro-bind-try /etc/pki          /etc/pki)
    # /etc/machine-id, /etc/hostname, /etc/os-release, /etc/passwd: BİLİNÇLİ bind EDİLMEDİ.

    # ── Fontlar ──
    args+=(--ro-bind-try /etc/fonts          /etc/fonts)
    args+=(--ro-bind-try /var/cache/fontconfig /var/cache/fontconfig)

    # ── Görüntü + ses (izole runtime → içine sadece gerekli soketler) ──
    args+=(--tmpfs "$XDG_RUNTIME_DIR")
    args+=(--chmod 0700 "$XDG_RUNTIME_DIR")
    args+=(--bind-try "$WL_SRC" "$WL_DST")                                 # Wayland (RW)
    args+=(--bind-try "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0") # PipeWire (RW)
    args+=(--bind-try "$XDG_RUNTIME_DIR/pulse"      "$XDG_RUNTIME_DIR/pulse")      # Pulse compat (RW)
    # X11 soketi BİLİNÇLİ olarak YOK → başka pencereleri gözetleme yüzeyi sıfır.
    # dbus oturum yolu YOK → portal/ekran-paylaşımı çalışmaz (kasıtlı sertleştirme).

    # ── Kullanıcı verisi (yazılabilir, yalnızca gerekenler) ──
    args+=(--bind "$PROFILE_HOME" "$HOME/.mozilla")        # kalıcı profil
    args+=(--bind "$CACHE_HOME"   "$HOME/.cache/mozilla")  # kalıcı cache
    args+=(--bind-try "$DOWNLOADS" "$DOWNLOADS")           # indirilenler
    # ~/.ssh, ~/.gnupg, ~/Documents, diğer dotfile'lar: HİÇ bind edilmedi → görünmez.

    # ── Ortam: --clearenv ile ambient env'i SIFIRLA, yalnızca gerekenleri geçir ──
    #    (least-privilege: host env değişkenleri güvenilmeyen tarayıcıya sızmasın)
    args+=(--clearenv)
    args+=(--setenv HOME "$HOME")
    args+=(--setenv USER "''${USER:-user}")
    args+=(--setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR")
    args+=(--setenv WAYLAND_DISPLAY "$WL_DST")
    args+=(--setenv XDG_SESSION_TYPE wayland)
    args+=(--setenv MOZ_ENABLE_WAYLAND 1)  # native Wayland (XWayland'a düşme)
    args+=(--setenv MOZ_DBUS_REMOTE 0)     # sandbox'ta dbus yok; remoting denemesin
    args+=(--setenv PATH "${hardenedFirefox}/bin")
    args+=(--setenv LANG "''${LANG:-C.UTF-8}")
    args+=(--setenv TZ "''${TZ:-UTC}")

    # ── Çalıştır: önce arken0 profilini idempotent garanti et, sonra Firefox'u exec et.
    #    default profili Firefox kendi üretir; arken0, profiles.ini oluştuktan sonra
    #    (ilk normal açılışın ardından) bir kez eklenir — başlangıç profilini ele geçirmez.
    exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" -- ${pkgs.bash}/bin/bash -c '
      set -euo pipefail
      ff="${hardenedFirefox}/bin/firefox"
      ini="$HOME/.mozilla/firefox/profiles.ini"
      if [ -f "$ini" ] && ! ${pkgs.gnugrep}/bin/grep -qi "^Name=arken0" "$ini"; then
        "$ff" -CreateProfile arken0 >/dev/null 2>&1 || true
      fi
      exec "$ff" --name firefox "$@"
    ' bash "$@"
  '';

  # ---------------------------------------------------------------------------
  # 3) Sandbox'a sabitlenmiş kendi .desktop girdimiz (üst-akışınki sandbox'ı atlardı)
  # ---------------------------------------------------------------------------
  firefox-desktop = pkgs.makeDesktopItem {
    name = "firefox";
    desktopName = "Firefox";
    genericName = "Web Tarayıcı";
    exec = "${firefox-sandboxed}/bin/firefox %U";
    icon = "firefox";
    startupNotify = true;
    startupWMClass = "firefox"; # labwc *firefox* kuralı + launcher ikon eşleşmesi
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeTypes = [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "firefox-hardened-sandboxed";
      # İkon + diğer asset'ler hardenedFirefox'tan gelir; bin/firefox ve .desktop'u eziyoruz.
      paths = [ hardenedFirefox ];
      postBuild = ''
        # bin/firefox → sandbox sarmalayıcı (tek, öngörülebilir giriş noktası)
        rm -f "$out/bin/firefox"
        ln -s ${firefox-sandboxed}/bin/firefox "$out/bin/firefox"

        # Üst-akış .desktop'ları sandbox'ı ATLAR → kaldır, kendimizinkini koy
        rm -f "$out"/share/applications/*.desktop
        install -Dm644 ${firefox-desktop}/share/applications/firefox.desktop \
          "$out/share/applications/firefox.desktop"
      '';
    })
  ];
}
