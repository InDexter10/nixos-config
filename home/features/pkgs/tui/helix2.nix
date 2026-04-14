{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [

      nil
      nixfmt-rfc-style

      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.prettier

      marksman
      lemminx
      libxml2
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

        file-picker = {
          hidden = true;
        };
      };

      keys.normal = {
        "G" = "goto_file_end";
        "g" = {
          "g" = "goto_file_start";
        };
        "esc" = [
          "collapse_selection"
          "keep_primary_selection"
        ];

        "C-s" = ":w";
        "C-q" = ":q";
      };

    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          };
        }

        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          language-servers = [
            "typescript-language-server"
            "eslint"
          ];
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              "babel"
            ];
          };
          language-servers = [
            "typescript-language-server"
            "eslint"
          ];
        }
        {
          name = "tsx";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          language-servers = [
            "typescript-language-server"
            "eslint"
          ];
        }

        {
          name = "html";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
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
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
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
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              "json"
            ];
          };
        }
        {
          name = "xml";
          auto-format = true;
          file-types = [
            "xml"
            "rc"
            "menu"
          ];
          language-servers = [ "lemminx" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          formatter = {
            command = "${pkgs.libxml2}/bin/xmllint";
            args = [
              "--format"
              "-"
            ];
          };
        }

        {
          name = "markdown";
          language-servers = [ "marksman" ];
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              "markdown"
            ];
          };
          auto-format = true;
        }
      ];

      language-server = {
        typescript-language-server = {
          command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" ];
        };
        eslint = {
          command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
          args = [ "--stdio" ];
        };
        marksman = {
          command = "${pkgs.marksman}/bin/marksman";
        };
        lemminx = {
          command = "${pkgs.lemminx}/bin/lemminx";
        };
      };
    };

    themes = {
      trans = {
        "inherits" = "hex_steel";

        "ui.background" = {
          bg = "none";
        };
        "ui.gutter" = {
          bg = "none";
        };

        # Attribute İsimleri (inputs, outputs)
        # "variable.other.member" = {
        #   fg = "#727b7c";
        #   modifiers = [ "bold" ];
        # };
        "comment" = {
          fg = "#417e8c";
        };
        "comment_doc" = {
          fg = "#234048";
        };

        palette = {
          t3 = "#766f6f";
          t4 = "#7e8182";
        };
        # palette = {
        #   t6 = "#98acaa"; # keyword "" arasındakiler hex poison
        # };

        # t9 noktalama işaretleri
        # t10 fonksiyon isimleri
        # t11 keyword.function
        # t8 if else ve operatorle = gibi

      };
    };
  };
}
