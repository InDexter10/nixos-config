# conky.nix  —  HOME-MANAGER modülü
#
# Config'i conky'nin KENDİLİĞİNDEN okuduğu standart yola yazar:
#   ~/.config/conky/conky.conf
# Böylece labwc autostart'taki düz "conky" komutu bile bu ayarı otomatik yükler;
# Nix store yolu / --config bayrağı / systemd graphical-session bağımlılığı gerekmez.
#
# labwc (wlroots) üzerinde Wayland-native, masaüstüne bütünleşik yarı saydam panel.
# Sağ tarafta, 300px. Veri: yerel (/proc, /sys).
#
# Kullanım : imports = [ ./conky.nix ];
#
# Başlatma (labwc): ~/.config/labwc/autostart dosyanıza şu İKİ satırı ekleyin:
#     dbus-update-activation-environment --all --systemd
#     conky &
#
# Hemen test: bir terminalde  ->  pkill conky 2>/dev/null; conky &
# Yazı tipi  : ilk seferde  fc-cache -f  + yeniden oturum.  Kontrol: fc-list | grep -i jetbrains

{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.conky
    pkgs.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  # Config dosyasını ~/.config/conky/conky.conf olarak yerleştir (store'a symlink).
  xdg.configFile."conky/conky.conf".text = ''
    conky.config = {
        out_to_x = false,
        out_to_wayland = true,
        own_window = true,
        own_window_type = 'desktop',
        own_window_class = 'conky',
        own_window_argb_visual = true,
        own_window_argb_value = 185,
        own_window_colour = '15161e',

        alignment = 'top_right',
        gap_x = 0,
        gap_y = 0,
        minimum_width = 300,
        maximum_width = 300,

        double_buffer = true,
        draw_shades = false,
        draw_borders = false,
        border_inner_margin = 16,
        border_outer_margin = 0,

        use_xft = true,
        xftalpha = 1,
        font = 'JetBrains Mono:size=10',
        override_utf8_locale = true,
        default_color = 'white',

        update_interval = 1.0,
        total_run_times = 0,
        cpu_avg_samples = 2,
        net_avg_samples = 2,
        no_buffers = true,
        use_spacer = 'none',
        short_units = true,
        format_human_readable = true,
    };

    conky.text = [[
    ''${color #7aa2f7}''${font JetBrains Mono:Bold:size=13}''${nodename}''${font}
    ''${color #565f89}''${sysname} ''${kernel} · ''${machine}
    ''${color #2a2e44}''${hr 1}
    ''${voffset 4}''${color #c0caf5}''${font JetBrains Mono:size=38}''${time %H:%M}''${font}
    ''${color #565f89}''${time %A, %d %B %Y}
    ''${voffset 6}''${color #565f89}Uptime''${alignr}''${color #c0caf5}''${uptime}

    ''${color #7dcfff}''${font JetBrains Mono:Bold:size=9}PROCESSOR''${font}''${alignr}''${color #c0caf5}''${cpu cpu0}%
    ''${color #7aa2f7}''${cpugraph cpu0 38,272 1a2a44 7aa2f7 -t}
    ''${color #565f89}Load ''${color #c0caf5}''${loadavg 1} ''${loadavg 2} ''${loadavg 3}''${alignr}''${color #565f89}''${freq_g} GHz
    ''${voffset 4}''${color #565f89}''${top name 1}''${alignr}''${color #c0caf5}''${top cpu 1}%
    ''${color #565f89}''${top name 2}''${alignr}''${color #c0caf5}''${top cpu 2}%
    ''${color #565f89}''${top name 3}''${alignr}''${color #c0caf5}''${top cpu 3}%

    ''${color #9ece6a}''${font JetBrains Mono:Bold:size=9}MEMORY''${font}''${alignr}''${color #c0caf5}''${mem} / ''${memmax}
    ''${color #9ece6a}''${memgraph 38,272 1a3324 9ece6a -t}
    ''${color #565f89}Used''${alignr}''${color #c0caf5}''${memperc}%
    ''${voffset 4}''${color #565f89}''${top_mem name 1}''${alignr}''${color #c0caf5}''${top_mem mem_res 1}
    ''${color #565f89}''${top_mem name 2}''${alignr}''${color #c0caf5}''${top_mem mem_res 2}
    ''${color #565f89}''${top_mem name 3}''${alignr}''${color #c0caf5}''${top_mem mem_res 3}

    ''${color #e0af68}''${font JetBrains Mono:Bold:size=9}STORAGE''${font}''${alignr}''${color #c0caf5}''${fs_used /} / ''${fs_size /}
    ''${color #e0af68}''${fs_bar 10,272 /}
    ''${color #565f89}Free''${alignr}''${color #c0caf5}''${fs_free /}

    ''${color #bb9af7}''${font JetBrains Mono:Bold:size=9}NETWORK''${font}''${alignr}''${color #565f89}''${addr wlan0}
    ''${voffset 2}''${color #565f89}Down ''${color #c0caf5}''${downspeed wlan0}''${alignr}''${color #565f89}Up ''${color #c0caf5}''${upspeed wlan0}
    ''${color #7dcfff}''${downspeedgraph wlan0 30,130 1a2a44 7dcfff -t}''${alignr}''${color #f7768e}''${upspeedgraph wlan0 30,130 3a1a24 f7768e -t}
    ''${color #565f89}Total ''${color #c0caf5}''${totaldown wlan0}''${alignr}''${color #565f89}Total ''${color #c0caf5}''${totalup wlan0}
    ]];
  '';
}
