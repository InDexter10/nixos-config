{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      sysup = "sudo nixos-rebuild switch --flake ~/nixos-config#msi-aio";
      homeup = "home-manager switch --flake ~/nixos-config#virt0";
      n = "cd /home/virt0/nixos-config";
      h = "cd ~";
      b = "cd /home/virt0/Books";
      l = "cd /home/virt0/.config/labwc";
    };

    history = {
      size = 5000;
      save = 5000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
    };

    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      globalias() {
         zle _expand_alias
         zle self-insert
      }
      zle -N globalias
    '';
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      nodejs = {
        symbol = "⬢ ";
        style = "bold green";
        disabled = false;
      };

      package = {
        symbol = "📦 ";
        disabled = false;
      };

      git_branch = {
        symbol = "🌱 ";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
