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
    #
    # labwc config dosyaları:
    #   rc.xml / menu.xml  -> XML grameri gömülü; .xml uzantısıyla otomatik
    #                         tanınır, burada ekstra tanım gerekmez.
    #   autostart          -> shell script  -> aşağıda bash'e eşlendi
    #   environment        -> KEY=value     -> aşağıda bash'e eşlendi
    #   themerc            -> labwc'ye özgü sözdizimi; uygun bir gramer
    #                         olmadığından bilerek atlandı.
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
      {
        # labwc'nin uzantısız 'autostart' ve 'environment' dosyalarını
        # bash olarak vurgula (tree-sitter, ekstra paket gerektirmez).
        #
        # NOT: Helix'te file-types override edilince varsayılanlarla
        # BİRLEŞMEZ, onların yerine geçer. Bu yüzden bash'in standart
        # eşleşmelerini de korumak için tekrar listelemek zorundayız;
        # yoksa .sh / .bashrc gibi dosyalar tanınmaz olur.
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
          # labwc:
          { glob = "autostart"; }
          { glob = "environment"; }
        ];
      }
    ];

    themes.trans = {
      inherits = "gruvbox";

      "ui.background".bg = "none";
      "ui.gutter".bg = "none";

      "comment".fg = "#396884";
      "comment.block.documentation".fg = "#234048";

      # Palet referans notları (tema ince ayarı için):
      #   t8  = if/else, operatör (=)     t9  = noktalama işaretleri
      #   t10 = fonksiyon isimleri        t11 = keyword.function
    };
  };
}
