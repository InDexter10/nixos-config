{ ... }:

let
  p = import ../../theme/palette.nix;

  uretim = "# BU DOSYA URETILIR - kaynak: wm/labwc/default.nix + theme/palette.nix.\n# Elle yapilan degisiklik bir sonraki \"home-manager switch\"te kaybolur.";
in
{
  wayland.systemd.target = "labwc-session.target";

  systemd.user.targets.labwc-session = {
    Unit = {
      Description = "labwc oturumu";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile."labwc" = {
    source = ./config;
    recursive = true;
  };

  xdg.configFile."labwc/autostart".text = ''
    ${uretim}

    # Bu ADIM ONCE gelmeli: asagidaki servisler WAYLAND_DISPLAY'i buradan
    # okur, yoksa "failed to create display" ile olurler.
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=labwc
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    systemctl --user start labwc-session.target

    # systemd birimi olmayan yardimcilar; labwc kapaninca surec agaciyla
    # birlikte sonlanirlar. Cokerlerse ekranda gorulur - o yuzden burada
    # kalabiliyorlar. (swayidle gorunur belirti vermedigi icin
    # ../../addons/swayidle.nix altinda systemd birimi olarak duruyor.)
    #
    # mkfifo -m 600: gostergeyi besleyen boruyu yalnizca sahibi yazabilsin.
    WOBSOCK="$XDG_RUNTIME_DIR/wob.fifo"
    rm -f "$WOBSOCK"
    mkfifo -m 600 "$WOBSOCK"
    tail -f "$WOBSOCK" | wob &

    swaybg -i "$HOME/${p.wallpaperFile}" -m fill &
  '';

  xdg.configFile."labwc/themerc-override".text = ''
    ${uretim}

    # Baslik cubugu kapali (rc.xml > windowRules), bu yuzden odakli pencereyi
    # ayirt eden tek isaret cerceve. Pasif kenarlik zemine esit: gorunmez.
    border.width: 3
    window.active.border.color: ${p.focus}
    window.inactive.border.color: ${p.bg}

    # Asagisi yalnizca dekorasyonu acilan pencereler icin gecerli.
    window.active.title.bg.color: ${p.elevated}
    window.inactive.title.bg.color: ${p.bg}
    window.active.label.text.color: ${p.fg}
    window.inactive.label.text.color: ${p.fgDim}
    window.label.text.justify: left
    window.titlebar.padding.width: 6
    window.titlebar.padding.height: 4
    window.button.width: 22
    window.button.height: 22
    window.button.spacing: 2
    window.active.button.unpressed.image.color: ${p.fg}
    window.inactive.button.unpressed.image.color: ${p.fgDim}
    window.button.hover.bg.color: ${p.hover}
    window.button.hover.bg.corner-radius: 3

    # Golge ayari BILEREK YOK: labwc golgeleri themerc'ten degil rc.xml'den
    # acar (<theme><dropShadows>, varsayilani "no") ve orada acilmiyor - buraya
    # yazilan window.*.shadow.* satirlari okunmadan atiliyordu. Istenirse once
    # rc.xml'e <dropShadows>yes</dropShadows> eklenmeli.

    menu.border.width: 1
    menu.border.color: ${p.border}
    menu.items.bg.color: ${p.elevated}
    menu.items.text.color: ${p.fg}
    menu.items.active.bg.color: ${p.accent}
    menu.items.active.text.color: ${p.accentFg}
    menu.items.padding.x: 10
    menu.items.padding.y: 5
    menu.title.bg.color: ${p.bg}
    menu.title.text.color: ${p.fgDim}
    menu.separator.color: ${p.border}
    menu.separator.width: 1
    menu.width.min: 140

    osd.bg.color: ${p.elevated}
    osd.border.width: 2
    osd.border.color: ${p.border}
    osd.label.text.color: ${p.fg}
    osd.window-switcher.preview.border.width: 2
    osd.window-switcher.preview.border.color: ${p.focusCycle}
    osd.window-switcher.style-thumbnail.item.active.bg.color: ${p.focusCycle}
    osd.window-switcher.style-thumbnail.item.active.border.color: ${p.focusCycle}
    osd.window-switcher.style-thumbnail.item.active.border.width: 2
    osd.window-switcher.style-thumbnail.item.icon.size: 24
    osd.window-switcher.style-thumbnail.item.padding: 6
    osd.window-switcher.style-thumbnail.padding: 10

    # "33" = %20 saydamlik; yaslama onizlemesi altindaki pencereyi gizlemesin.
    snapping.overlay.edge.bg.enabled: yes
    snapping.overlay.edge.bg.color: ${p.accent}33
    snapping.overlay.edge.border.enabled: yes
    snapping.overlay.edge.border.width: 2
    snapping.overlay.edge.border.color: ${p.accent}
    snapping.overlay.region.bg.enabled: yes
    snapping.overlay.region.bg.color: ${p.accent}33
    snapping.overlay.region.border.enabled: yes
    snapping.overlay.region.border.width: 2
    snapping.overlay.region.border.color: ${p.accent}
  '';
}
