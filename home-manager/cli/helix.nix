{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      nil
      nixfmt
      vscode-langservers-extracted
      prettier
    ];

    settings = {
      theme = "gruvbox";

      editor = {
        line-number = "absolute";
        mouse = false;
        bufferline = "multiple";
        true-color = true;
        cursorline = true;
        color-modes = true;

        rulers = [ 100 ];
        text-width = 100;

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
        language-servers = [ ];
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "markdown"
          ];
        };
      }
      {
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

  };
}
