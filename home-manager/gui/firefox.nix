# firefox.nix — kullanıcı seviyesinde (home-manager), hardened + bwrap sandbox.
# Tek giriş noktası: bin/firefox = sandbox sarmalayıcı. .desktop de aynı sarmalayıcıya sabit.
{ pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # 1) Politika ile sertleştirilmiş Firefox (wrapFirefox.extraPolicies)
  # ---------------------------------------------------------------------------
  hardenedFirefox = pkgs.firefox.override {
    extraPolicies = {
      # -- Telemetri / arka plan veri toplama --
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableDefaultBrowserAgent = true; # arka plan telemetri ajanı
      DontCheckDefaultBrowser = true; # "varsayılan tarayıcı yap" nag'i yok

      # -- Hesap / Sync --
      DisableFirefoxAccounts = true; # Sync istersen bu satırı sil

      # -- Güncelleme: Firefox'u Nix yönetir --
      DisableAppUpdate = true;
      DisableSystemAddonUpdate = true;

      # -- DNS: sistem resolved + DoT (Quad9) kullanılsın; Firefox kendi DoH'unu
      #    açıp sistem çözümleyiciyi ATLAMASIN (network.nix ile tutarlı). --
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };

      # -- DRM (Widevine = Google kapalı kaynak modülü). Netflix/Spotify için
      #    Enabled = true yap. --
      EncryptedMediaExtensions = {
        Enabled = false;
        Locked = true;
      };

      # -- Parola: Bitwarden kullanılıyor --
      OfferToSaveLogins = false;
      DisablePasswordReveal = true;

      # -- Ağ sızıntısı --
      NetworkPrediction = false; # prefetch / speculative DNS

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
    mkdir -p "$PROFILE_HOME" "$CACHE_HOME" "$DOWNLOADS"

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
    # /etc/machine-id, /etc/hostname, /etc/os-release: BİLİNÇLİ olarak bind EDİLMEDİ.

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

    # ── Ortam ──
    args+=(--setenv MOZ_ENABLE_WAYLAND 1)  # native Wayland (XWayland'a düşme)

    exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" -- \
      ${hardenedFirefox}/bin/firefox --name firefox "$@"
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
