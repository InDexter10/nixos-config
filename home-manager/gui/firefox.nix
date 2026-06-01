{ pkgs, ... }:

let
  hardenedFirefox = pkgs.firefox.override {
    extraPolicies = {
      # -- Telemetri / arka plan veri toplama --
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableDefaultBrowserAgent = true; # arka planda çalışan telemetri ajanı
      # -- Hesap/Sync: Mozilla sunucusuna veri + sistem bilgisi yüzeyi --
      DisableFirefoxAccounts = true; # Sync istiyorsan bu satırı kaldır
      # -- Güncelleme: Firefox'u Nix yönetir, kendi güncellemesini yapmasın --
      DisableAppUpdate = true;
      # -- DRM: Widevine = Google'ın kapalı kaynak modülü; truva-atı felsefesine aykırı --
      EncryptedMediaExtensions = {
        Enabled = false;
      }; # Netflix/Spotify için true yap
      # -- Parola: Bitwarden kullanıyorsun, Firefox'un kendi yöneticisi kapalı --
      OfferToSaveLogins = false;
      DisablePasswordReveal = true;
      # -- Ağ sızıntısı --
      NetworkPrediction = false; # prefetch / speculative DNS
      # -- İlk çalıştırma / arka plan gürültüsü --
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisableSetDesktopBackground = true;
    };
  };

  firefox-sandboxed = pkgs.writeShellScriptBin "firefox" ''
    set -euo pipefail

    PROFILE_HOME="$HOME/.mozilla-sandbox"
    mkdir -p "$PROFILE_HOME"

    args=()

    # ── Namespace izolasyonu: sistemi Firefox'tan ayır ──
    args+=(--unshare-all)          # tüm namespace'leri izole et (user/pid/ipc/uts/cgroup/mount/net)
    args+=(--share-net)            # ...ağ hariç (tarayıcı için zorunlu)
    args+=(--hostname localhost)   # gerçek makine adını GİZLE (UTS ns --unshare-all'dan gelir)
    args+=(--die-with-parent)      # başlatıcı ölünce sandbox da ölsün (orphan kalmasın)
    args+=(--new-session)          # yeni oturum -> TIOCSTI terminal enjeksiyonuna karşı

    # ── Çekirdek sistem (salt-okunur) ──
    args+=(--ro-bind /nix/store /nix/store)               # TODO: closure-daraltma (aşağıdaki nota bak)
    args+=(--proc /proc)                                  # taze, izole /proc
    args+=(--tmpfs /tmp)                                  # izole geçici alan
    args+=(--ro-bind /etc/resolv.conf /etc/resolv.conf)   # DNS sunucusu
    args+=(--ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf)  # ad çözümleme sırası
    args+=(--ro-bind-try /etc/hosts /etc/hosts)           # localhost vb.
    args+=(--ro-bind-try /etc/ssl /etc/ssl)               # CA (kurumsal CA gerekirse)
    args+=(--ro-bind-try /etc/static /etc/static)         # NixOS: ssl/fonts symlink hedefleri buraya
    args+=(--ro-bind-try /etc/fonts /etc/fonts)           # fontconfig
    # /etc/machine-id, /etc/hostname, /etc/os-release: BİLİNÇLİ olarak bind EDİLMEDİ.
    #   Sahte de yaratmadık -> Firefox kalıcı makine kimliğini / gerçek host'u göremez.

    # ── GPU: Intel UHD 600 (Gemini Lake, Mesa) ──
    args+=(--dev /dev)                                    # minimal /dev (null, urandom, ...)
    args+=(--dev-bind /dev/dri /dev/dri)                  # DRM render node -> donanım hızlandırma
    args+=(--ro-bind /run/opengl-driver /run/opengl-driver)  # Mesa/VA-API sürücü yolu (ZORUNLU)

    # ── Görüntü + ses (labwc = wlroots Wayland) ──
    args+=(--tmpfs "$XDG_RUNTIME_DIR")                    # izole runtime dizini...
    args+=(--ro-bind-try "$XDG_RUNTIME_DIR/wayland-0" "$XDG_RUNTIME_DIR/wayland-0")   # ...içine Wayland soketi
    args+=(--ro-bind-try "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0") # PipeWire ses
    args+=(--ro-bind-try "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse")           # Pulse uyumluluk (varsa)
    # X11 soketi BİLİNÇLİ olarak YOK -> başka pencereleri gözetleme yüzeyi sıfır.

    # ── Kullanıcı verisi (yazılabilir, yalnızca gerekenler) ──
    args+=(--bind "$PROFILE_HOME" "$HOME/.mozilla")       # kalıcı profil -> içeride ~/.mozilla
    args+=(--bind-try "$HOME/Downloads" "$HOME/Downloads")  # indirilenler
    # ~/.ssh, ~/.gnupg, ~/Documents, diğer dotfile'lar: HİÇ bind edilmedi -> görünmez.

    # ── Ortam ──
    args+=(--setenv MOZ_ENABLE_WAYLAND 1)                 # native Wayland (XWayland'a düşme)

    exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" -- \
      ${hardenedFirefox}/bin/firefox -P arken1 --name firefox "$@"
  '';

in
{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "firefox-sandboxed";
      paths = [ hardenedFirefox ]; # .desktop + ikon + asset'ler buradan
      postBuild = ''
        # bin/firefox'u sandbox wrapper'a sabitle (öngörülebilir, tek giriş noktası)
        rm -f $out/bin/firefox
        ln -s ${firefox-sandboxed}/bin/firefox $out/bin/firefox
      '';
    })
  ];
}
