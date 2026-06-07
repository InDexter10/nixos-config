# ============================================================================
# mk-sandboxed-app.nix — bwrap ile sandbox'lanmış uygulama üreticisi
# ----------------------------------------------------------------------------
# firefox.nix / uyap.nix desenlerinin parametrik genellemesi. Ortak ve sabit
# olması GEREKEN sertleştirme çekirdeği (namespace izolasyonu, salt-okunur
# /nix/store, izole /proc-/dev-/tmp, font/sertifika, runtime-dir + 0700,
# --clearenv) tek yerdedir. Uygulamaya özgü farklar AÇIK PARAMETRE'dir.
#
# Tasarım ilkeleri: default-deny, en az yetki, deterministik, sürümden bağımsız.
# Bilinçli olarak DAHİL EDİLMEYENLER (parametreyle açılmadıkça): ağ, GPU, dbus,
# X11 soketi, ses, ev dizini, /etc/machine-id, /etc/passwd.
#
# Kullanım:
#   let mk = import ../lib/mk-sandboxed-app.nix { inherit pkgs lib config; };
#   in { home.packages = [ (mk { name = "vlc"; package = pkgs.vlc; ... }) ]; }
# ============================================================================
{
  pkgs,
  lib,
  config,
}:

{
  name, # ikili + sarmalayıcı + WMClass adı
  package, # üst-akış paketi (gerçek ikili + ikon + asset kaynağı)
  binName ? name, # paket içindeki gerçek ikilinin adı
  exec ? "${package}/bin/${binName}", # sandbox içinde çalıştırılacak gerçek ikili
  desktopName, # .desktop "Name=" alanı
  genericName ? "",
  icon ? name,
  categories ? [ "Utility" ],
  mimeTypes ? [ ],
  startupWMClass ? name,
  desktopArgs ? "%U", # .desktop Exec eki (%U/%F/%f)

  display ? "wayland", # "wayland" | "x11" | "both"
  net ? false, # --share-net + resolver/CA bind'leri
  gpu ? false, # /dev/dri + opengl-driver + /sys-drm + LIBVA
  vaapiDriver ? "iHD", # UHD 600 (Gemini Lake) → iHD
  audio ? false, # PipeWire/Pulse soketleri
  passwd ? false, # /etc/passwd + /etc/group (örn. Java)
  isolatedConfig ? true, # özel, kalıcı ~/.config-~/.cache-~/.local/share

  roDirs ? [ ], # salt-okunur dosya allowlist'i (host yolu = sandbox yolu)
  rwDirs ? [ ], # yazılabilir dosya allowlist'i
  extraEnv ? { }, # ek --setenv (örn. QT_QPA_PLATFORM)
  extraArgs ? [ ], # ek ham bwrap argümanları (zaten kabuk-escape'li)
}:

let
  inherit (lib)
    optionalString
    concatMapStringsSep
    concatStringsSep
    mapAttrsToList
    escapeShellArg
    ;

  user = config.home.username;

  wantWayland = display == "wayland" || display == "both";
  wantX11 = display == "x11" || display == "both";

  roDirLines = concatMapStringsSep "\n" (
    d: "    args+=(--ro-bind-try ${escapeShellArg d} ${escapeShellArg d})"
  ) roDirs;

  rwDirLines = concatMapStringsSep "\n" (
    d: "    args+=(--bind-try ${escapeShellArg d} ${escapeShellArg d})"
  ) rwDirs;

  extraArgLines = concatMapStringsSep "\n" (a: "    args+=(${a})") extraArgs;

  envLines = concatStringsSep "\n" (
    mapAttrsToList (k: v: "    args+=(--setenv ${escapeShellArg k} ${escapeShellArg v})") extraEnv
  );

  # Allowlist klasörleri host'ta garanti et (yoksa --bind-try sessizce atlar).
  allowMkLines = concatMapStringsSep "\n" (
    d: "    mkdir -p ${escapeShellArg d} 2>/dev/null || true"
  ) (roDirs ++ rwDirs);

  # ---------------------------------------------------------------------------
  # bwrap sarmalayıcı — bin adı "name" (PATH'te ham ikiliyi gölgeler)
  # ---------------------------------------------------------------------------
  wrapper = pkgs.writeShellScriptBin name ''
    set -euo pipefail

    XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    ${optionalString isolatedConfig ''
      # İzole, kalıcı uygulama verisi — host'ta ~/.sandboxes altında, sandbox
      # içinde standart XDG yollarına bağlanır. ~/.sandboxes sandbox'ta GÖRÜNMEZ.
      SBOX="$HOME/.sandboxes/${name}"
      mkdir -p "$SBOX/config" "$SBOX/cache" "$SBOX/share"
    ''}
${allowMkLines}
    ${optionalString wantX11 ''
      XAUTH="''${XAUTHORITY:-$HOME/.Xauthority}"
      if [ ! -f "$XAUTH" ]; then
        : > "$HOME/.Xauthority" || true
        XAUTH="$HOME/.Xauthority"
      fi
    ''}
    ${optionalString wantWayland ''
      WL_NAME="''${WAYLAND_DISPLAY:-wayland-0}"
      case "$WL_NAME" in
        /*) WL_SRC="$WL_NAME"; WL_DST="$WL_NAME" ;;
        *)  WL_SRC="$XDG_RUNTIME_DIR/$WL_NAME"; WL_DST="$WL_SRC" ;;
      esac
    ''}

    args=()

    # ── Namespace izolasyonu ──
    args+=(--unshare-all)        # user/pid/ipc/uts/cgroup/mount/net
    ${optionalString net "args+=(--share-net)        # ...ağ hariç (yalnız net=true)"}
    args+=(--hostname localhost) # gerçek makine adını gizle
    args+=(--die-with-parent)    # başlatıcı ölünce sandbox da ölsün
    args+=(--new-session)        # TIOCSTI terminal enjeksiyonuna karşı

    # ── Çekirdek sistem (salt-okunur) ──
    args+=(--ro-bind /nix/store /nix/store)
    args+=(--proc /proc)
    args+=(--dev /dev)
    args+=(--tmpfs /tmp)
    args+=(--tmpfs /dev/shm)

    # ── Fontlar + sistem teması/ikon/mime (salt-okunur, sırf gizli-olmayan veri) ──
    args+=(--ro-bind-try /etc/fonts /etc/fonts)
    args+=(--ro-bind-try /etc/static /etc/static)
    args+=(--ro-bind-try /etc/xdg /etc/xdg)
    args+=(--ro-bind-try /var/cache/fontconfig /var/cache/fontconfig)
    args+=(--ro-bind-try /run/current-system/sw/share /run/current-system/sw/share)
    ${optionalString net ''
      # ── Ağ: isim çözümleme + CA sertifikaları (yalnız net=true) ──
      args+=(--ro-bind-try /etc/resolv.conf /etc/resolv.conf)
      args+=(--ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf)
      args+=(--ro-bind-try /etc/hosts /etc/hosts)
      args+=(--ro-bind-try /etc/ssl /etc/ssl)
      args+=(--ro-bind-try /etc/pki /etc/pki)
    ''}
    ${optionalString passwd ''
      args+=(--ro-bind-try /etc/passwd /etc/passwd)
      args+=(--ro-bind-try /etc/group /etc/group)
    ''}
    ${optionalString gpu ''
      # ── GPU / VA-API (firefox.nix ile birebir bind seti) ──
      args+=(--dev-bind /dev/dri /dev/dri)
      args+=(--ro-bind /run/opengl-driver /run/opengl-driver)
      args+=(--ro-bind-try /sys/dev/char /sys/dev/char)
      args+=(--ro-bind-try /sys/devices /sys/devices)
      args+=(--ro-bind-try /sys/class/drm /sys/class/drm)
    ''}

    # ── Runtime dizini (izole) + ekran/ses soketleri ──
    args+=(--tmpfs "$XDG_RUNTIME_DIR")
    args+=(--chmod 0700 "$XDG_RUNTIME_DIR")   # Qt'nin Flatpak/izin kontrolü için zorunlu
    ${optionalString wantWayland ''args+=(--bind-try "$WL_SRC" "$WL_DST")''}
    ${optionalString audio ''
      args+=(--bind-try "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0")
      args+=(--bind-try "$XDG_RUNTIME_DIR/pulse"      "$XDG_RUNTIME_DIR/pulse")
    ''}
    ${optionalString wantX11 ''
      # NOT: X11 soketi paylaşımı XWayland istemcileri arası gözetlemeye açıktır;
      # yalnız native Wayland desteklemeyen uygulamalar için (display="x11").
      args+=(--bind-try /tmp/.X11-unix /tmp/.X11-unix)
      args+=(--ro-bind-try "$XAUTH" "$XAUTH")
    ''}
    ${optionalString isolatedConfig ''
      args+=(--bind "$SBOX/config" "$HOME/.config")
      args+=(--bind "$SBOX/cache"  "$HOME/.cache")
      args+=(--bind "$SBOX/share"  "$HOME/.local/share")
    ''}

    # ── Dosya erişim allowlist'i (host yolu = sandbox yolu) ──
${roDirLines}
${rwDirLines}

    # ── Ortam: --clearenv ile sıfırla, yalnız gerekenleri geçir ──
    args+=(--clearenv)
    args+=(--setenv HOME "$HOME")
    args+=(--setenv USER "''${USER:-${user}}")
    args+=(--setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR")
    args+=(--setenv PATH "${package}/bin")
    args+=(--setenv LANG "''${LANG:-C.UTF-8}")
    args+=(--setenv TZ "''${TZ:-UTC}")
    args+=(--setenv XDG_DATA_DIRS "${package}/share:/run/current-system/sw/share")
    args+=(--setenv XDG_CONFIG_DIRS "/etc/xdg")
    ${optionalString isolatedConfig ''
      args+=(--setenv XDG_CONFIG_HOME "$HOME/.config")
      args+=(--setenv XDG_CACHE_HOME  "$HOME/.cache")
      args+=(--setenv XDG_DATA_HOME   "$HOME/.local/share")
    ''}
    ${optionalString wantWayland ''
      args+=(--setenv WAYLAND_DISPLAY "$WL_DST")
      args+=(--setenv XDG_SESSION_TYPE wayland)
    ''}
    ${optionalString wantX11 ''
      args+=(--setenv DISPLAY "''${DISPLAY:-:0}")
      args+=(--setenv XAUTHORITY "$XAUTH")
    ''}
    ${optionalString gpu ''args+=(--setenv LIBVA_DRIVER_NAME "${vaapiDriver}")''}
${envLines}
${extraArgLines}

    args+=(--chdir "$HOME")

    exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" -- ${exec} "$@"
  '';

  # ---------------------------------------------------------------------------
  # Sandbox'a sabitlenmiş kendi .desktop girdimiz (üst-akışınki sandbox'ı atlardı)
  # ---------------------------------------------------------------------------
  desktop = pkgs.makeDesktopItem {
    inherit name desktopName genericName icon categories mimeTypes startupWMClass;
    exec = "${wrapper}/bin/${name} ${desktopArgs}";
    startupNotify = true;
  };
in
# İkon + asset'ler üst-akış paketinden; bin yalnız sarmalayıcıya indirgenir.
pkgs.symlinkJoin {
  name = "${name}-sandboxed";
  paths = [ package ];
  postBuild = ''
    # bin/ ağacını sandbox sarmalayıcısına indirge → ham ikililer (örn. cvlc)
    # PATH'e sızmasın; tek, öngörülebilir giriş noktası kalsın.
    rm -rf "$out/bin"
    mkdir -p "$out/bin"
    ln -s ${wrapper}/bin/${name} "$out/bin/${name}"

    # Üst-akış .desktop'ları sandbox'ı ATLAR → kaldır, kendimizinkini koy.
    rm -f "$out"/share/applications/*.desktop 2>/dev/null || true
    install -Dm644 ${desktop}/share/applications/${name}.desktop \
      "$out/share/applications/${name}.desktop"
  '';
}
