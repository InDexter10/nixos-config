{ config, pkgs, ... }:

let
  fdBase = "${pkgs.fd}/bin/fd --hidden --follow --exclude .git";
in
{
  home.packages = [ pkgs.fd ];

  programs.zsh = {
    enable = true;

    autocd = true;
    defaultKeymap = "emacs";

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
      ];
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^[OA"
      ];
      searchDownKey = [
        "^[[B"
        "^[OB"
      ];
    };

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";

      extended = true;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
    };

    setOptions = [
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"

      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"

      "INTERACTIVE_COMMENTS"
      "EXTENDED_GLOB"
      "NUMERIC_GLOB_SORT"
      "NO_BEEP"

      "NO_FLOW_CONTROL"
    ];

    dirHashes = {
      nix = "${config.home.homeDirectory}/.config/nixconf";
      dl = "${config.home.homeDirectory}/Downloads";
      doc = "${config.home.homeDirectory}/Documents";
      books = "${config.home.homeDirectory}/Books";
    };

    shellAliases = {
      g = "git";
      h = "cd ~";
      b = "cd ~/Books";
      d = "cd ~/Documents/Aİ";
      dd = "cd ~/Documents";
      l = "cd ~/.config/labwc";
      n = "cd ~/.config/nixconf";
      t = "timew summary :all";

      "..." = "cd ../..";
      "...." = "cd ../../..";

      homeup = "home-manager switch --flake ~/.config/nixconf#dex";
      sysup = "sudo nixos-rebuild switch --flake ~/.config/nixconf#msi";
      lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
    };

    shellGlobalAliases = {
      G = "| grep -i";
      E = "| less -R";
      J = "| jq";
      NE = "2>/dev/null";
    };

    completionInit = ''
      autoload -Uz compinit
      _zcompdump="${config.xdg.cacheHome}/zsh/zcompdump"
      mkdir -p "''${_zcompdump:h}"
      compinit -d "$_zcompdump"
      unset _zcompdump
    '';

    initContent = ''
      zstyle ':completion:*' menu select

      # 1) buyuk/kucuk harf duyarsiz   2) ayirici sonrasi kismi eslesme
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
      zstyle ':completion:*:warnings' format '%F{red}eslesme yok%f'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Yavas tamamlamalari (systemd birimleri, paket listeleri) onbellekle.
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/zcompcache"
      zstyle ':completion:*' special-dirs true

      # Home/End/Delete: terminfo kodlari ancak terminal "uygulama moduna"
      # gectikten sonra gecerli olur, asagidaki iki kanca bunu saglar.
      zmodload zsh/terminfo

      if (( ''${+terminfo[smkx]} && ''${+terminfo[rmkx]} )); then
        autoload -Uz add-zle-hook-widget
        _zle_appmode_on()  { echoti smkx }
        _zle_appmode_off() { echoti rmkx }
        add-zle-hook-widget line-init   _zle_appmode_on
        add-zle-hook-widget line-finish _zle_appmode_off
      fi

      [[ -n ''${terminfo[khome]} ]] && bindkey -- "''${terminfo[khome]}" beginning-of-line
      [[ -n ''${terminfo[kend]}  ]] && bindkey -- "''${terminfo[kend]}"  end-of-line
      [[ -n ''${terminfo[kdch1]} ]] && bindkey -- "''${terminfo[kdch1]}" delete-char

      # terminfo bunlari tanimlamaz.
      bindkey -- "^[[1;5C" forward-word
      bindkey -- "^[[1;5D" backward-word

      # Engellemez, yalnizca Enter'dan once goze carpar.
      typeset -gA ZSH_HIGHLIGHT_PATTERNS
      ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('rm -fr *' 'fg=white,bold,bg=red')
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "${fdBase} --type f";
    defaultOptions = [
      "--height=45%"
      "--layout=reverse"
      "--border=sharp"
      "--info=inline"
    ];

    fileWidgetCommand = "${fdBase} --type f";
    fileWidgetOptions = [ "--preview 'head -200 {}'" ];

    changeDirWidgetCommand = "${fdBase} --type d";
    changeDirWidgetOptions = [ "--preview 'ls -1 --color=always {}'" ];

    historyWidgetOptions = [
      "--exact"
      "--reverse"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship.enable = true;
}
