{ pkgs, ... }:

{
  # Paketler ve Aliaslar
  home.packages = [
    pkgs.git-lfs
    pkgs.gh
  ];

  home.shellAliases = {
    g = "git";
    lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
  };

  # DÜZELTME 1: Delta artık bağımsız bir program (Warning Fix)
  programs.delta = {
    enable = true;
    enableGitIntegration = true; # Git ile otomatik bağla
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;

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
