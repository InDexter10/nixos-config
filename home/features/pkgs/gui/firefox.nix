{ pkgs, config, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;

  # ════════════════════════════════════════════════
  #  BUBBLEWRAP SANDBOX WRAPPER
  # ════════════════════════════════════════════════
  # Firefox yalnızca ~/.mozilla ve ~/Downloads'a erişebilir.
  # Dosya yükleme xdg-desktop-portal üzerinden yapılır (host'ta çalışır).
  # GPU, Wayland, PipeWire, D-Bus erişimi korunur.

  firefox-sandboxed = pkgs.writeShellScriptBin "firefox-safe" ''
    XDG_RUN="/run/user/$(id -u)"

    mkdir -p "${homeDir}/.mozilla"
    mkdir -p "${homeDir}/Downloads"

    exec ${pkgs.bubblewrap}/bin/bwrap \
      --ro-bind /nix/store /nix/store \
      --ro-bind /run/current-system /run/current-system \
      --ro-bind /run/opengl-driver /run/opengl-driver \
      --ro-bind /run/systemd/resolve /run/systemd/resolve \
      --ro-bind /run/dbus /run/dbus \
      --ro-bind /etc /etc \
      --ro-bind /sys /sys \
      --proc /proc \
      --dev-bind /dev /dev \
      --tmpfs /tmp \
      \
      --tmpfs "${homeDir}" \
      --bind "${homeDir}/.mozilla" "${homeDir}/.mozilla" \
      --bind "${homeDir}/Downloads" "${homeDir}/Downloads" \
      \
      --bind "$XDG_RUN" "$XDG_RUN" \
      --setenv XDG_RUNTIME_DIR "$XDG_RUN" \
      --setenv HOME "${homeDir}" \
      --setenv USER "${username}" \
      \
      --setenv WAYLAND_DISPLAY "''${WAYLAND_DISPLAY:-wayland-0}" \
      --setenv MOZ_ENABLE_WAYLAND "1" \
      --setenv XDG_SESSION_TYPE "wayland" \
      --setenv XDG_CURRENT_DESKTOP "labwc:wlroots" \
      --setenv LIBVA_DRIVER_NAME "iHD"\
      \
      --setenv GTK_THEME "Adwaita-dark" \
      --setenv XCURSOR_THEME "Bibata-Modern-Classic" \
      --setenv XCURSOR_SIZE "18" \
      \
      --die-with-parent \
      --new-session \
      \
      ${config.programs.firefox.finalPackage}/bin/firefox "$@"
  '';
  # ════════════════════════════════════════════════
  #  DOĞRULAMA SCRIPTİ
  # ════════════════════════════════════════════════

  firefox-verify = pkgs.writeShellScriptBin "firefox-verify" ''
    PROFILE_DIR=$(find "${homeDir}/.mozilla/firefox" -maxdepth 1 -name "*.hardened" -type d | head -1)

    if [ -z "$PROFILE_DIR" ]; then
      echo "HATA: 'hardened' profili bulunamadi."
      echo "Firefox'u en az bir kez baslatip kapatin."
      exit 1
    fi

    PREFS_FILE="$PROFILE_DIR/prefs.js"

    if [ ! -f "$PREFS_FILE" ]; then
      echo "HATA: prefs.js bulunamadi: $PREFS_FILE"
      exit 1
    fi

    echo ""
    echo "  Firefox Hardening Dogrulama Raporu"
    echo "  ==================================="
    echo ""

    PASS=0
    FAIL=0

    check_pref() {
      local pref="$1"
      local expected="$2"
      local label="$3"
      local actual=$(grep "\"$pref\"" "$PREFS_FILE" | tail -1)

      if echo "$actual" | grep -q "$expected"; then
        echo "  [OK] $label"
        PASS=$((PASS + 1))
      else
        echo "  [!!] $label"
        echo "       Beklenen: $expected"
        echo "       Bulunan:  $actual"
        FAIL=$((FAIL + 1))
      fi
    }

    # Parrot
    PARROT=$(grep "_user.js.parrot" "$PREFS_FILE" | tail -1)
    if echo "$PARROT" | grep -q "SUCCESS"; then
      echo "  [OK] Parrot: Tum ayar bloklari uygulandi"
      PASS=$((PASS + 1))
    else
      echo "  [!!] Parrot: Ayar bloklari eksik veya hatali!"
      FAIL=$((FAIL + 1))
    fi

    echo ""
    echo "  -- Fingerprinting --"
    check_pref "privacy.resistFingerprinting" "false" "RFP kapali (FPP aktif)"
    check_pref "privacy.fingerprintingProtection" "true" "FPP aktif"
    check_pref "privacy.fingerprintingProtection.overrides" "AllTargets" "FPP AllTargets,-FrameRate"

    echo ""
    echo "  -- GPU --"
    check_pref "media.ffmpeg.vaapi.enabled" "true" "VA-API"
    check_pref "gfx.webrender.all" "true" "WebRender"
    check_pref "media.hardware-video-decoding.enabled" "true" "HW video decode"

    echo ""
    echo "  -- Guvenlik --"
    check_pref "dom.security.https_only_mode" "true" "HTTPS-Only"
    check_pref "security.ssl.require_safe_negotiation" "true" "Safe TLS"
    check_pref "security.OCSP.require" "true" "OCSP Hard-Fail"
    check_pref "security.cert_pinning.enforcement_level" "2" "Strict PKP"
    check_pref "network.IDN_show_punycode" "true" "Punycode"

    echo ""
    echo "  -- Gizlilik --"
    check_pref "privacy.sanitize.sanitizeOnShutdown" "true" "Kapanista temizle"
    check_pref "browser.contentblocking.category" "strict" "ETP Strict"
    check_pref "network.http.referer.XOriginTrimmingPolicy" "2" "Referer kisitli"
    check_pref "privacy.userContext.enabled" "true" "Container Tabs"

    echo ""
    echo "  -- Telemetri --"
    check_pref "datareporting.policy.dataSubmissionEnabled" "false" "Veri gonderimi"
    check_pref "toolkit.telemetry.enabled" "false" "Telemetri"
    check_pref "app.normandy.enabled" "false" "Normandy"

    echo ""
    echo "  -- XDG Portal --"
    check_pref "widget.use-xdg-desktop-portal.file-picker" "1" "Portal file picker"

    echo ""
    echo "  ==================================="
    echo "  Sonuc: $PASS basarili, $FAIL basarisiz"
    echo ""

    if [ "$FAIL" -gt 0 ]; then
      echo "  UYARI: Bazi ayarlar uygulanamamis."
      echo "  about:config uzerinden kontrol edin."
      exit 1
    else
      echo "  Tum ayarlar basariyla dogrulandi."
    fi

    echo ""
    echo "  Sandbox Notu:"
    echo "  firefox-safe ile baslatildiginda yalnizca"
    echo "  ~/.mozilla ve ~/Downloads erisime aciktir."
    echo "  Test: file:///home/${username}/Documents acmayi deneyin."
  '';

in
{
  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFormHistory = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      FirefoxHome = {
        Search = false;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.hardened = {
      id = 0;
      isDefault = true;

      settings = {
        # ══ PARROT ══
        "_user.js.parrot" = "SUCCESS: No no he's not dead, he's, he's restin'!";

        # ══ GPU ══
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "gfx.webrender.all" = true;
        "widget.dmabuf.force-enabled" = true;
        "media.ffvpx.enabled" = false;

        # ══ FPP ══
        "privacy.resistFingerprinting" = false;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.overrides" = "+AllTargets,-FrameRate";
        "privacy.fingerprintingProtection.pbmode" = true;
        "privacy.fingerprintingProtection.remoteOverrides.enabled" = false;
        "privacy.window.maxInnerWidth" = 1600;
        "privacy.window.maxInnerHeight" = 900;
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "privacy.spoof_english" = 1;
        "browser.link.open_newwindow" = 3;
        "browser.link.open_newwindow.restriction" = 0;
        "widget.non-native-theme.use-theme-accent" = false;

        # ══ XDG PORTAL ══
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;

        # ══ 0100: STARTUP ══
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 0;
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";

        # ══ 0200: GEOLOCATION ══
        "geo.provider.ms-windows-location" = false;
        "geo.provider.use_corelocation" = false;
        "geo.provider.use_geoclue" = false;

        # ══ 0300: QUIETER FOX ══
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;

        # ══ 0400: SAFE BROWSING ══
        "browser.safebrowsing.downloads.remote.enabled" = false;

        # ══ 0600: BLOCK IMPLICIT OUTBOUND ══
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        "network.http.speculative-parallel-limit" = 0;
        "browser.places.speculativeConnect.enabled" = false;

        # ══ 0700: DNS / PROXY / SOCKS ══
        "network.proxy.socks_remote_dns" = true;
        "network.file.disable_unc_paths" = true;
        "network.gio.supported-protocols" = "";

        # ══ 0800: LOCATION BAR / SEARCH ══
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.amp.featureGate" = false;
        "browser.urlbar.fakespot.featureGate" = false;
        "browser.urlbar.mdn.featureGate" = false;
        "browser.urlbar.weather.featureGate" = false;
        "browser.urlbar.wikipedia.featureGate" = false;
        "browser.urlbar.yelp.featureGate" = false;
        "browser.urlbar.pocket.featureGate" = false;
        "browser.formfill.enable" = false;
        "browser.search.separatePrivateDefault" = true;
        "browser.search.separatePrivateDefault.ui.enabled" = true;

        # ══ 0900: PASSWORDS ══
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;

        # ══ 1000: DISK AVOIDANCE ══
        "browser.cache.disk.enable" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "media.memory_cache_max_size" = 65536;
        "browser.sessionstore.privacy_level" = 2;
        "toolkit.winRegisterApplicationRestart" = false;
        "browser.shell.shortcutFavicons" = false;

        # ══ 1200: HTTPS / TLS / OCSP ══
        "security.ssl.require_safe_negotiation" = true;
        "security.tls.enable_0rtt_data" = false;
        "security.OCSP.enabled" = 1;
        "security.OCSP.require" = true;
        "security.cert_pinning.enforcement_level" = 2;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_send_http_background_request" = false;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;

        # ══ 1600: REFERERS ══
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        # ══ 1700: CONTAINERS ══
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;

        # ══ 2000: MEDIA / WEBRTC ══
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "media.peerconnection.ice.default_address_only" = true;

        # ══ 2400: DOM ══
        "dom.disable_window_move_resize" = true;

        # ══ 2600: MISCELLANEOUS ══
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.uitour.enabled" = false;
        "devtools.debugger.remote-enabled" = false;
        "permissions.manager.defaultsUrl" = "";
        "network.IDN_show_punycode" = true;
        "pdfjs.disabled" = false;
        "pdfjs.enableScripting" = false;
        "browser.tabs.searchclipboardfor.middleclick" = false;
        "browser.contentanalysis.enabled" = false;
        "browser.contentanalysis.default_result" = 0;
        "security.csp.reporting.enabled" = false;
        "browser.download.useDownloadDir" = false;
        "browser.download.alwaysOpenPanel" = false;
        "browser.download.manager.addToRecentDocs" = false;
        "browser.download.always_ask_before_handling_new_types" = true;
        "extensions.enabledScopes" = 5;
        "extensions.postDownloadThirdPartyPrompt" = false;

        # ══ 2700: ETP ══
        "browser.contentblocking.category" = "strict";

        # ══ 2800: SHUTDOWN & SANITIZING ══
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
        "privacy.clearOnShutdown_v2.downloads" = false;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.clearSiteData.cache" = true;
        "privacy.clearSiteData.cookiesAndStorage" = false;
        "privacy.clearSiteData.historyFormDataAndDownloads" = false;
        "privacy.clearSiteData.browsingHistoryAndDownloads" = false;
        "privacy.clearSiteData.formdata" = true;
        "privacy.clearHistory.cache" = true;
        "privacy.clearHistory.cookiesAndStorage" = false;
        "privacy.clearHistory.historyFormDataAndDownloads" = false;
        "privacy.clearHistory.browsingHistoryAndDownloads" = false;
        "privacy.clearHistory.formdata" = true;
        "privacy.sanitize.timeSpan" = 0;

        # ══ 6000: DON'T TOUCH ══
        "extensions.blocklist.enabled" = true;
        "network.http.referer.spoofSource" = false;
        "security.dialog_enable_delay" = 1000;
        "privacy.firstparty.isolate" = false;
        "extensions.webcompat.enable_shims" = true;
        "security.tls.version.enable-deprecated" = false;
        "extensions.webcompat-reporter.enabled" = false;
        "extensions.quarantinedDomains.enabled" = true;

        # ══ 8500: TELEMETRY ══
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";

        # ══ 9000: NON-PROJECT ══
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.urlbar.showSearchTerms.enabled" = false;
        "browser.shopping.experience2023.enabled" = false;
      };
    };
  };

  # ════════════════════════════════════════════════
  #  PAKETLER
  # ════════════════════════════════════════════════
  home.packages = [
    firefox-sandboxed # Kullanim: firefox-safe
    firefox-verify # Kullanim: firefox-verify
    pkgs.bubblewrap
  ];

  # ════════════════════════════════════════════════
  #  LABWC KISAYOLU NOTU
  # ════════════════════════════════════════════════
  #
  # rc.xml'e ekle:
  #   <keybind key="W-b">
  #     <action name="Execute" command="firefox-safe"/>
  #   </keybind>
  #
  # Dogrulama:
  #   1. firefox-safe ile baslat
  #   2. file:///home/KULLANICI/Documents ac — ERISILEMEZ olmali
  #   3. file:///home/KULLANICI/Downloads ac — ERISIME ACIK olmali
  #   4. Terminalde: firefox-verify
  #
}
