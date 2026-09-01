{ pkgs, ... }:

# Duzenleme katmani. defaultEditor = true -> $EDITOR; yazi'nin "edit"
# opener'i ve alacritty'nin Ctrl+Shift+E ipucu da buraya yonlenir.
# "trans" temasi arka planini boyamaz (ui.background.bg = none), yani zemin
# alacritty'nin zeminidir.

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # Helix'in calisma zamani PATH'ine eklenir (LSP + formatter).
    extraPackages = with pkgs; [
      nil
      nixfmt
      vscode-langservers-extracted # html / css / json / eslint
      prettier
    ];

    settings = {
      theme = "trans";

      editor = {
        line-number = "absolute";
        mouse = false;
        bufferline = "multiple";
        true-color = true;
        cursorline = true;
        color-modes = true;

        # nixfmt'in satir genisligiyle ayni.
        rulers = [ 100 ];
        text-width = 100;

        # Arka planla ayni renkte olduklarinda nerede bittikleri belirsizdi.
        popup-border = "all";

        soft-wrap = {
          enable = true;
          wrap-indicator = "↪ ";
          max-indent-retain = 40;
        };

        indent-guides = {
          render = true;
          character = "┊";
          skip-levels = 1;
        };

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };

        # Otomatik algilama XWayland varken x-clip'e kayabiliyor.
        clipboard-provider = "wayland";

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
          ];
          center = [
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-encoding"
            "file-type"
          ];
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        file-picker.hidden = true;
      };

      keys.normal = {
        "G" = "goto_file_end";
        "g"."g" = "goto_file_start";
        "esc" = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        "C-s" = ":w";
        "C-q" = ":q";
      };
    };

    # Yalnizca extraPackages ile desteklenen diller.
    # labwc rc.xml / menu.xml XML grameriyle otomatik taninir; themerc icin
    # uygun bir gramer olmadigindan atlandi.
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "nixfmt";
      }
      {
        name = "html";
        auto-format = true;
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "html"
          ];
        };
      }
      {
        name = "css";
        auto-format = true;
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "css"
          ];
        };
      }
      {
        name = "json";
        auto-format = true;
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "json"
          ];
        };
      }
      {
        name = "markdown";
        auto-format = true;
        language-servers = [ ]; # marksman kurulu degil
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "markdown"
          ];
        };
      }
      {
        # labwc'nin uzantisiz autostart ve environment dosyalarini bash
        # olarak vurgula.
        #
        # DIKKAT: file-types override edilince varsayilanlarla BIRLESMEZ,
        # yerine gecer. Bash'in standart eslesmeleri bu yuzden tekrar
        # listelenmek zorunda; yoksa .sh / .bashrc taninmaz olur.
        name = "bash";
        file-types = [
          "sh"
          "bash"
          "zsh"
          "ksh"
          "csh"
          { glob = ".bashrc"; }
          { glob = ".bash_profile"; }
          { glob = ".bash_login"; }
          { glob = ".bash_logout"; }
          { glob = ".profile"; }
          { glob = ".zshrc"; }
          { glob = ".zshenv"; }
          { glob = ".zprofile"; }
          { glob = ".zlogin"; }
          { glob = ".zlogout"; }
          { glob = "PKGBUILD"; }
          { glob = "APKBUILD"; }
          { glob = "ebuild"; }
          { glob = "eclass"; }
          { glob = "autostart"; }
          { glob = "environment"; }
        ];
      }
    ];

    themes.trans = {
      inherits = "gruvbox";

      "ui.background".bg = "none";
      "ui.gutter".bg = "none";
    };
  };
}
