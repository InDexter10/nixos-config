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
        "variable.other.member" = {
          fg = "#727b7c";
          modifiers = [ "bold" ];
        };
        "comment" = {
          fg = "#417e8c";
          modifiers = [ "italic" ];
        };
      };
    };
  };
}
