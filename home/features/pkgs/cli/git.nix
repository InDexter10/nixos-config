{ pkgs, ... }:

{
  # Sadece alias'lar kaldı, gereksiz home.packages bloğunu tamamen sildik.
  home.shellAliases = {
    g = "git";
    lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
  };

  # Modern Diff Aracı (Harika seçim)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;

    # İŞTE SİHİRLİ DOKUNUŞ: Perl ve Python çöplerinden arınmış saf Git!
    package = pkgs.gitMinimal;

    # Bu ayar zaten git-lfs'yi gerektiği gibi kurup ayarlıyor.
    lfs.enable = true;

    settings = {
      user = {
        name = "dx5";
        email = "247799176+InDexter10@users.noreply.github.com";
        signingKey = "~/.ssh/id_ed25519.pub";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "hx";

      # Pro Düzey SSH İmzalama Ayarları
      gpg.format = "ssh";
      "user \"signing\"".key = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };

    ignores = [
      ".direnv/"
      "result"
      "*.swp"
    ];
  };
}
