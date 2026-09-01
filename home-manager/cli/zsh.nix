{ config, pkgs, ... }:

# $EDITOR (helix) ve "y" sarmalayicisi (yazi) kendi modullerinde tanimli,
# burada tekrarlanmaz.
#
# fzf / zoxide / fd YENI PAKET DEGIL: ucu de cli/yazi.nix uzerinden zaten
# depoda. Buradaki kullanim onlari kabuga da aciyor, ek indirme yok.
#
# claude-code kabugu sik ac-kapa yaptigi icin .zshrc ucuz tutuldu: agir
# eklenti yigini yok, tamamlama onbellegi sabit bir XDG yolunda.

let
  # .git haric, gizli dosyalar dahil - yapilandirma depolarinda aranan sey
  # cogu zaman gizli dosyadir.
  fdBase = "${pkgs.fd}/bin/fd --hidden --follow --exclude .git";
in
{
  # fzf'in gezginleri fd'yi cagirir; yazi'nin extraPackages'i kabuga gorunmez.
  home.packages = [ pkgs.fd ];

  programs.zsh = {
    enable = true;

    # Dizin adini yazip Enter cd yerine gecer; ".." ve "../.." de birer dizin
    # oldugu icin ayrica alias gerekmez.
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
      # brackets: kapanmamis parantez/tirnagi kirmizi yapar - uzun tek
      # satirlik komutlarda (jq, awk, sh -c) hatayi calistirmadan gosterir.
      highlighters = [
        "main"
        "brackets"
      ];
    };

    # Yukari/asagi ok, yazdigin ONEKLE eslesen gecmiste gezinir.
    # Iki kod da baglaniyor: terminal uygulama modunda ^[OA/^[OB, normal
    # modda ^[[A/^[[B uretir; yalnizca birini baglamak ozelligin bazen
    # sessizce calismamasi demektir.
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

      extended = true; # zaman damgasi + calisma suresi
      share = true;
      ignoreDups = true;
      ignoreSpace = true; # basinda BOSLUK olan komut kaydedilmez
      saveNoDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;

      # HIST_FCNTL_LOCK elle yazilmiyor: home-manager'in zsh modulu onu
      # kosulsuz ekliyor.
    };

    setOptions = [
      # Dizin yigini: "cd -" bir oncekine, "cd -2" iki oncekine, "dirs -v" liste.
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"

      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY" # "!!" gibi genislemeleri calistirmadan once satira yazar

      "INTERACTIVE_COMMENTS"
      "EXTENDED_GLOB"
      "NUMERIC_GLOB_SORT"
      "NO_BEEP"

      # Ctrl+S terminali dondurmesin: helix'te o tus kaydetmeye bagli.
      "NO_FLOW_CONTROL"
    ];

    # Alias'tan farki: yol olarak her yerde gecerli -> hx ~nix/flake.nix
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
      d = "cd ~/Downloads";
      dd = "cd ~/Documents";
      l = "cd ~/.config/labwc";
      n = "cd ~/.config/nixconf";

      "..." = "cd ../..";
      "...." = "cd ../../..";

      homeup = "home-manager switch --flake ~/.config/nixconf#dex";
      sysup = "sudo nixos-rebuild switch --flake ~/.config/nixconf#msi";
      lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
    };

    # Satirin herhangi bir yerinde genisler:  journalctl -u foo E
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
      #    (nixo -> nixOS)                (h-m -> home-manager)
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
      zstyle ':completion:*:warnings' format '%F{red}eslesme yok%f'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Yavas tamamlamalari (systemd birimleri, paket listeleri) onbellekle.
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/zcompcache"
      zstyle ':completion:*' special-dirs true

      # Home/End/Delete cogu kurulumda calismaz cunku terminal "uygulama
      # moduna" gecmeden terminfo kodlari gecerli olmaz. Asagidaki iki kanca
      # tam olarak bunu duzeltir.
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

  # Ctrl+R gecmiste bulanik arama, Ctrl+T dosya yolu ekle, Alt+C alt dizine cd.
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

    # --exact: "git c" yazinca alakasiz sonuclarin one cikmasini onler.
    historyWidgetOptions = [
      "--exact"
      "--reverse"
    ];
  };

  # z <parca> -> sik gidilen dizine atlar, zi -> fzf ile sec.
  # Yukaridaki kisa alias'lar sabit hedefler icin duruyor; zoxide onlarin
  # yerine gecmez, ogrenilmemis dizinleri tamamlar.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship.enable = true;
}
