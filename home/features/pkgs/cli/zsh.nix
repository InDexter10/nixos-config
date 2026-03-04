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
    };

    history = {
      size = 5000;
      save = 5000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
    };

    initContent = ''
      # 1. Otomatik tamamlama için Fish tarzı büyük/küçük harf eşleştirme
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      # 2. "Anti-Hippi" Kısaltma Genişletici (Inline Expansion)
      # Alias yazıp BOŞLUK tuşuna bastığında komutun aslını açıkça ekrana yazar.
      globalias() {
         zle _expand_alias
         zle self-insert
      }
      zle -N globalias
      bindkey " " globalias
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
