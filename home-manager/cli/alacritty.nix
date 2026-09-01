{ ... }:

# Ucluenin zemini: helix'in "trans" temasi arka planini boyamaz, yazi da
# arayuzunu ANSI renkleriyle cizer. Yani asagidaki 16 renk ucunun de renk
# sistemidir. Palet Gruvbox Dark - helix temasi zaten gruvbox'tan turuyor.

let
  bg = "#282828";
  bg2 = "#504945";
  fg = "#ebdbb2"; # zemine karsi 10.4:1
  fgDim = "#a89984"; # zemine karsi  5.6:1
  fgBright = "#fbf1c7";
  yellow = "#fabd2f"; # arama, ipucu, vi imleci
in
{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        opacity = 0.98;
        padding = {
          x = 8;
          y = 8;
        };
        dynamic_padding = true;
      };

      scrolling = {
        history = 50000;
        multiplier = 5;
      };

      font = {
        # Kalin/italik yuzler ACIKCA veriliyor: tanimlanmazsa alacritty
        # normal yuzu sentetik olarak kalinlastirir ve metin bulaniklasir.
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };

        size = 11.0;

        # y = satir araligi; yogun terminal ciktisinda en ucuz okunabilirlik
        # kazanci.
        offset = {
          x = 0;
          y = 2;
        };
      };

      colors = {
        primary = {
          background = bg;
          foreground = fg;
          dim_foreground = fgDim;
          bright_foreground = fgBright;
        };

        cursor = {
          text = bg;
          cursor = fg;
        };
        vi_mode_cursor = {
          text = bg;
          cursor = yellow;
        };

        # Secim metin RENGINI korur; ters cevirmek sozdizimi renklerini
        # yok ediyordu.
        selection = {
          text = "CellForeground";
          background = bg2;
        };

        search = {
          matches = {
            foreground = bg;
            background = fgDim;
          };
          focused_match = {
            foreground = bg;
            background = yellow;
          };
        };

        hints = {
          start = {
            foreground = bg;
            background = yellow;
          };
          end = {
            foreground = bg;
            background = fgDim;
          };
        };

        footer_bar = {
          foreground = bg;
          background = fgDim;
        };

        normal = {
          black = bg;
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = fgDim;
        };

        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = yellow;
          blue = "#83a598";
          magenta = "#d3869b";
          cyan = "#8ec07c";
          white = fg;
        };

        # DIM RENKLER ELLE TANIMLI. Tanimli degilse alacritty normal renkleri
        # ~%66 karartarak uretir ve koyu zeminde neredeyse okunmaz; Claude Code
        # ikincil bilgiyi (dosya yollari, aciklamalar) dim ile yazar.
        dim = {
          black = "#32302f";
          red = "#9d3a35";
          green = "#6e6d17";
          yellow = "#a2731a";
          blue = "#3a6a6d";
          magenta = "#8a4d68";
          cyan = "#527a55";
          white = "#7c6f64";
        };
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        unfocused_hollow = true;
      };

      selection.save_to_clipboard = true;
      mouse.hide_when_typing = true;

      # Claude Code isi bitirdiginde veya girdi bekledigincde calar.
      # Rahatsiz ederse: duration = 0.
      bell = {
        animation = "EaseOutQuad";
        duration = 100;
        color = yellow;
      };

      hints = {
        # DIKKAT: bu liste varsayilanin YERINE gecer, uzerine eklenmez -
        # alacritty'nin hazir URL ipucu da bu yuzden yeniden tanimlaniyor.
        #
        # Regex'ler bilerek ters egik cizgi icermiyor: Nix -> TOML uretici
        # onu kacirmadigi icin "\s" gecersiz TOML uretiyor. Ayni anlam
        # kacissiz veriliyor (gercek bosluk, "\." yerine [.]).
        enabled = [
          # Ctrl+Shift+O : baglantiyi tarayicida ac
          {
            regex = "(https://|http://|ftp://|file:|mailto:|git://|ssh://)[^ <>\"'`{}|^]+";
            hyperlinks = true;
            post_processing = true;
            persist = false;
            command = "xdg-open";
            mouse.enabled = true;
            binding = {
              key = "O";
              mods = "Control|Shift";
            };
          }

          # Ctrl+Shift+E : "dosya:satir"i YENI BIR alacritty penceresinde
          # helix ile o satirda acar; mevcut pencere Claude Code'da kalir.
          # helix "dosya:satir:sutun" bicimini dogrudan kabul eder.
          {
            regex = "[a-zA-Z0-9_./-]+[.][a-zA-Z0-9]+:[0-9]+(:[0-9]+)?";
            hyperlinks = false;
            post_processing = false;
            persist = false;
            command = {
              program = "alacritty";
              args = [
                "msg"
                "create-window"
                "--command"
                "hx"
              ];
            };
            binding = {
              key = "E";
              mods = "Control|Shift";
            };
          }
        ];
      };

      keyboard.bindings = [
        # Ayni surecte yeni pencere; ayri bir alacritty baslatmaktan belirgin
        # sekilde az bellek kullanir.
        {
          key = "Enter";
          mods = "Control|Shift";
          action = "CreateNewWindow";
        }
        {
          key = "K";
          mods = "Control|Shift";
          action = "ClearHistory";
        }
      ];
    };
  };
}
