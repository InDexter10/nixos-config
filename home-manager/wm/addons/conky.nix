{
  config,
  lib,
  pkgs,
  ...
}:

let
  netStatus = pkgs.writeShellScript "conky-net-status" ''
    set -u

    IP_BIN=${pkgs.iproute2}/bin/ip
    AWK_BIN=${pkgs.gawk}/bin/awk
    IW_BIN=${pkgs.iw}/bin/iw
    CAT_BIN=${pkgs.coreutils}/bin/cat
    DATE_BIN=${pkgs.coreutils}/bin/date

    C_MUTED="\''${color #565f89}"
    C_FG="\''${color #c0caf5}"
    C_GREEN="\''${color #9ece6a}"
    C_RED="\''${color #f7768e}"
    C_BLUE="\''${color #7dcfff}"
    AR="\''${alignr}"

    emit() { printf '%s\n' "$1"; }

    iface=$($IP_BIN route show default 2>/dev/null | $AWK_BIN 'NR==1{print $5}')

    if [ -z "''${iface:-}" ]; then
      emit "''${C_RED}● Offline''${C_MUTED}''${AR}bağlantı yok"
      exit 0
    fi

    if [ -d "/sys/class/net/$iface/wireless" ]; then wifi=1; else wifi=0; fi

    ipaddr=$($IP_BIN -4 -o addr show "$iface" 2>/dev/null | $AWK_BIN 'NR==1{split($4,a,"/"); print a[1]}')
    [ -z "''${ipaddr:-}" ] && ipaddr="—"

    rx=$($CAT_BIN "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
    tx=$($CAT_BIN "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
    now=$($DATE_BIN +%s.%N)
    state="''${XDG_RUNTIME_DIR:-/tmp}/conky-net-$iface.state"

    prx=0; ptx=0; pnow=0
    if [ -r "$state" ]; then read -r prx ptx pnow < "$state" || true; fi
    printf '%s %s %s\n' "$rx" "$tx" "$now" > "$state" 2>/dev/null || true

    read -r down up <<EOF
    $($AWK_BIN -v rx="$rx" -v tx="$tx" -v now="$now" -v prx="''${prx:-0}" -v ptx="''${ptx:-0}" -v pnow="''${pnow:-0}" '
    function human(x,   u, i) {
      split("B K M G", u, " ");
      i = 1; while (x >= 1024 && i < 4) { x /= 1024; i++ }
      return (i == 1) ? sprintf("%d%s", x, u[i]) : sprintf("%.1f%s", x, u[i])
    }
    BEGIN {
      if (pnow <= 0) { print human(0), human(0); }
      else {
        dt = now - pnow; if (dt <= 0) dt = 1;
        dr = (rx - prx) / dt; if (dr < 0) dr = 0;
        ut = (tx - ptx) / dt; if (ut < 0) ut = 0;
        print human(dr), human(ut);
      }
    }')
    EOF
    [ -z "''${down:-}" ] && down="0B"
    [ -z "''${up:-}" ] && up="0B"

    if [ "$wifi" -eq 1 ]; then
      link=$($IW_BIN dev "$iface" link 2>/dev/null)
      essid=$(printf '%s\n' "$link" | $AWK_BIN -F': ' '/SSID/{print $2; exit}')
      sigdbm=$(printf '%s\n' "$link" | $AWK_BIN '/signal:/{print $2; exit}')
      qual=$($AWK_BIN -v s="''${sigdbm:-}" 'BEGIN{ if(s==""){print "?"; exit} q=2*(s+100); if(q<0)q=0; if(q>100)q=100; printf "%d", q }')
      [ -z "''${essid:-}" ] && essid="—"
      emit "''${C_GREEN}● ''${C_FG}$essid''${C_MUTED}''${AR}Wi-Fi ''${C_FG}$qual%"
      emit "''${C_MUTED}IP''${AR}''${C_FG}$ipaddr"
    else
      emit "''${C_GREEN}● ''${C_FG}Ethernet''${C_MUTED}''${AR}''${C_FG}$ipaddr"
    fi
    emit "''${C_MUTED}↓ ''${C_BLUE}$down/s''${C_MUTED}''${AR}↑ ''${C_RED}$up/s"
  '';
in
{
  home.packages = [
    pkgs.conky
  ];
  fonts.fontconfig.enable = true;

  xdg.configFile."conky/conky.conf".text = ''
    conky.config = {
        out_to_x = false,
        out_to_wayland = true,
        own_window = true,
        own_window_type = 'desktop',
        own_window_class = 'conky',
        own_window_argb_visual = true,
        own_window_argb_value = 220,
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
        font = 'JetBrainsMono Nerd Font:size=10',
        override_utf8_locale = true,
        default_color = 'white',

        update_interval = 2.0,
        total_run_times = 0,
        cpu_avg_samples = 2,
        no_buffers = true,
        use_spacer = 'none',
        short_units = true,
        format_human_readable = true,
    };

    conky.text = [[
    ''${color #7aa2f7}''${font JetBrainsMono Nerd Font:Bold:size=13}''${nodename}''${font}
    ''${color #565f89}''${sysname} ''${kernel} · ''${machine}
    ''${color #2a2e44}''${hr 1}
    ''${voffset 4}''${color #c0caf5}''${font JetBrainsMono Nerd Font:size=38}''${time %H:%M}''${font}
    ''${color #565f89}''${time %A, %d %B %Y}
    ''${voffset 6}''${color #565f89} Uptime''${alignr}''${color #c0caf5}''${uptime_short}

    ''${color #7dcfff}''${font JetBrainsMono Nerd Font:Bold:size=9} PROCESSOR''${font}''${alignr}''${color #c0caf5}''${cpu cpu0}%
    ''${color #7aa2f7}''${cpugraph cpu0 38,268 1a2a44 7aa2f7 -t}
    ''${color #565f89}Load ''${color #c0caf5}''${loadavg 1} ''${loadavg 2} ''${loadavg 3}''${alignr}''${color #565f89}''${freq_g} GHz
    ''${voffset 4}''${color #565f89}''${top name 1}''${alignr}''${color #c0caf5}''${top cpu 1}%
    ''${color #565f89}''${top name 2}''${alignr}''${color #c0caf5}''${top cpu 2}%
    ''${color #565f89}''${top name 3}''${alignr}''${color #c0caf5}''${top cpu 3}%

    ''${color #9ece6a}''${font JetBrainsMono Nerd Font:Bold:size=9} MEMORY''${font}''${alignr}''${color #c0caf5}''${mem} / ''${memmax}
    ''${color #9ece6a}''${memgraph 38,268 1a3324 9ece6a -t}
    ''${color #565f89}Used''${alignr}''${color #c0caf5}''${memperc}%
    ''${voffset 4}''${color #565f89}''${top_mem name 1}''${alignr}''${color #c0caf5}''${top_mem mem_res 1}
    ''${color #565f89}''${top_mem name 2}''${alignr}''${color #c0caf5}''${top_mem mem_res 2}
    ''${color #565f89}''${top_mem name 3}''${alignr}''${color #c0caf5}''${top_mem mem_res 3}

    ''${color #e0af68}''${font JetBrainsMono Nerd Font:Bold:size=9} STORAGE''${font}''${alignr}''${color #c0caf5}''${fs_used /} / ''${fs_size /}
    ''${color #e0af68}''${fs_bar 10,268 /}
    ''${color #565f89}Free''${alignr}''${color #c0caf5}''${fs_free /}

    ''${color #bb9af7}''${font JetBrainsMono Nerd Font:Bold:size=9} NETWORK''${font}
    ''${voffset 2}''${execpi 2 ${netStatus}}
    ]];
  '';
}
