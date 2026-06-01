{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # Helix'in çalışma zamanı PATH'ine eklenen araçlar (LSP + formatter).
    extraPackages = with pkgs; [
      nil # nix LSP (Helix varsayılanı)
      nixfmt-rfc-style # nix formatter (binary adı: nixfmt)
      vscode-langservers-extracted # html / css / json / eslint LSP'leri
      prettier # html / css / json / markdown formatter
    ];

    settings = {
      theme = "trans";

      editor = {
        line-number = "absolute";
        mouse = false;
        bufferline = "multiple";
        true-color = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
          ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
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

    # Yalnızca extraPackages ile desteklenen diller.
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
        language-servers = [ ]; # marksman kurulu değil → LSP kapalı
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "markdown"
          ];
        };
      }
    ];

    themes.trans = {
      inherits = "hex_steel";

      "ui.background".bg = "none";
      "ui.gutter".bg = "none";

      "comment".fg = "#417e8c";
      "comment.block.documentation".fg = "#234048";

      palette = {
        t3 = "#766f6f";
        t4 = "#7e8182";
      };
      # Palet referans notları (tema ince ayarı için):
      #   t8  = if/else, operatör (=)     t9  = noktalama işaretleri
      #   t10 = fonksiyon isimleri        t11 = keyword.function
    };
  };
}
