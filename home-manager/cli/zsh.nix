{ config, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    syntaxHighlighting.enable = true;

    history = {
      size = 5000;
      save = 5000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true; # HIST_IGNORE_DUPS
      ignoreSpace = true; # HIST_IGNORE_SPACE
      share = true; # SHARE_HISTORY
    };

    shellAliases = {
      g = "git";
      h = "cd ~";
      b = "cd ~/Books";
      l = "cd ~/.config/labwc";
      n = "cd ~/nixos-config";
      homeup = "home-manager switch --flake ~/nixos-config#dex";
      sysup = "sudo nixos-rebuild switch --flake ~/nixos-config#msi";
      lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
    };

    initContent = ''
      # Büyük/küçük harf duyarsız tamamlama (küçük yazınca büyüğü de eşleşir).
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # SHARE_HISTORY ile eşzamanlı oturumlarda güvenli yazım için fcntl kilidi.
      setopt HIST_FCNTL_LOCK

    '';
  };

  programs.starship.enable = true;
}
