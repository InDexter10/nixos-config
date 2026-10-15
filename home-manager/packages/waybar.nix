{ pkgs, ... }:

let
  # Waybar'in kendi temasi.
  p = {
    base = "#3c3836";
    elevated = "#504945";
    hover = "#5a524c";
    border = "#665c54";
    fg = "#e6d2b0";
    fgDim = "#c7b899";
    accent = "#9ac5ba";
    accentFg = "#282828";
    urgent = "#ed7d78";
    warn = "#d8a657";

    fontUI = "Inter";
    fontIcon = "Symbols Nerd Font";
    fontUISize = 10;
  };
in
{
  home.packages = [ pkgs.pavucontrol ];

  programs.waybar = {
    enable = true;

    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "bottom";
      height = 34;
      spacing = 2;

      modules-left = [
        "ext/workspaces"
        "wlr/taskbar"
      ];

      modules-right = [
        "wireplumber"
        "backlight"
        "privacy"
        "tray"
        "idle_inhibitor"
        "cpu"
        "memory"
        "network"
        "clock"
      ];

      "ext/workspaces" = {
        format = "{name}";
        sort-by-id = true;
        all-outputs = true;
        on-click = "activate";
        tooltip = false;
      };

      "wlr/taskbar" = {
        format = "{icon}";
        icon-size = 20;
        tooltip = false;
        sort-by-app-id = false;
        active-first = false;
        on-click = "minimize-raise";
        on-click-middle = "close";
        on-click-right = "maximize";
        all-outputs = false;
      };

      privacy = {
        icon-size = 16;
        icon-spacing = 6;
        transition-duration = 200;
        modules = [
          {
            type = "screenshare";
            tooltip = false;
          }
          {
            type = "audio-in";
            tooltip = false;
          }
        ];
      };

      tray = {
        icon-size = 18;
        spacing = 8;
        show-passive-items = false;
        tooltip = false;
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰈈";
          deactivated = "󰈉";
        };
        tooltip = false;
      };

      cpu = {
        interval = 3;
        format = "CPU {usage}%";
        states = {
          warning = 70;
          critical = 90;
        };
        on-click = "foot --title htop htop --sort-key PERCENT_CPU";
        tooltip = false;
      };

      memory = {
        interval = 5;
        format = "RAM {used:0.1f}G";
        tooltip = false;
        states = {
          warning = 75;
          critical = 90;
        };
        on-click = "foot --title htop htop --sort-key PERCENT_MEM";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        max-volume = 100;
        scroll-step = 5;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
        tooltip = false;
      };

      backlight = {
        device = "intel_backlight";
        interval = 2;
        format = "{icon} {percent}%";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        scroll-step = 5.0;
        min-brightness = 5.0;
        tooltip = false;
      };

      network = {
        interval = 5;
        family = "ipv4";
        format-wifi = "{icon}";
        format-ethernet = "󰈀";
        format-linked = "󰈀";
        format-disconnected = "󰤭";
        format-disabled = "󰤭";
        format-icons = [
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        tooltip = false;
        on-click = "foot --title nmtui nmtui-connect";
        on-click-right = "foot --title nmtui nmtui";
      };

      clock = {
        interval = 30;
        format = "{:%d.%m.%Y  %H:%M}";
        tooltip = false;
      };
    };

    style = ''
      * {
        /* Ikinci sira YALNIZCA ikon kod noktalari icindir. */
        font-family: "${p.fontUI}", "${p.fontIcon}";
        font-size: ${toString p.fontUISize}pt;
        border: none;
        border-radius: 0;
        box-shadow: none;
        text-shadow: none;
        min-height: 0;
      }

      window#waybar {
        background-color: ${p.elevated};
        color: ${p.fg};
        border-top: 1px solid ${p.border};
      }

      #workspaces {
        margin-left: 4px;
      }
      #workspaces button {
        padding: 0 12px;
        margin: 5px 2px;
        color: ${p.fgDim};
        background-color: transparent;
        border-radius: 3px;
        transition: background-color 120ms linear, color 120ms linear;
      }
      #workspaces button:hover {
        background-color: ${p.hover};
        color: ${p.fg};
      }
      #workspaces button.active {
        background-color: ${p.accent};
        color: ${p.accentFg};
      }
      /* Dolgu uzerindeki metin accent dolgusuyla ayni kurala tabi: koyu. */
      #workspaces button.urgent {
        background-color: ${p.urgent};
        color: ${p.accentFg};
      }

      #taskbar {
        margin-left: 8px;
      }
      #taskbar button {
        min-width: 24px;
        padding: 0 8px;
        margin: 5px 2px;
        color: ${p.fgDim};
        background-color: ${p.base};
        border-radius: 3px;
        transition: background-color 120ms linear, color 120ms linear;
      }
      #taskbar button:hover {
        background-color: ${p.hover};
        color: ${p.fg};
      }
      /* Odaktaki pencere: alt kenarda vurgu cizgisi. */
      #taskbar button.active {
        background-color: ${p.hover};
        color: ${p.fg};
        box-shadow: inset 0 -2px ${p.accent};
      }
      #taskbar button.minimized {
        background-color: transparent;
        color: ${p.fgDim};
      }

      #privacy,
      #tray,
      #idle_inhibitor,
      #cpu,
      #memory,
      #wireplumber,
      #backlight,
      #network,
      #clock {
        padding: 0 9px;
        margin: 5px 1px;
        color: ${p.fg};
        background-color: transparent;
        border-radius: 3px;
      }

      /* Panelin oynamasini engelleyen kisim: icerik kisalinca kutu daralmaz. */
      #cpu        { min-width: 64px; }
      #memory     { min-width: 72px; }
      #wireplumber{ min-width: 60px; }
      #backlight  { min-width: 60px; }
      #network    { min-width: 22px; }
      #clock      { min-width: 118px; }

      #idle_inhibitor:hover,
      #cpu:hover,
      #memory:hover,
      #wireplumber:hover,
      #backlight:hover,
      #network:hover,
      #clock:hover {
        background-color: ${p.hover};
      }

      #cpu.warning,
      #memory.warning {
        color: ${p.warn};
      }
      #cpu.critical,
      #memory.critical {
        color: ${p.urgent};
      }

      #wireplumber.muted {
        color: ${p.fgDim};
      }

      #network.disconnected,
      #network.disabled {
        color: ${p.urgent};
      }

      #idle_inhibitor.activated {
        color: ${p.warn};
      }

      #privacy {
        color: ${p.urgent};
        padding: 0 6px;
      }

      /* GTK3'te ":empty" desteklenmez; waybar bos tepsiyi zaten gizler. */
      #tray > .needs-attention {
        background-color: ${p.urgent};
        border-radius: 3px;
      }
    '';
  };
}
