{ pkgs, config, ... }:

let
  signingKey = "~/.ssh/id_ed25519.pub";
  userEmail = "247799176+InDexter10@users.noreply.github.com";

  signingPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqaMyPu8JTUM/0OEcX7VPN/q7kqzO7kqve3HUW6r95q";
in
{

  xdg.configFile."git/allowed_signers".text = ''
    ${userEmail} namespaces="git" ${signingPubKey}
  '';

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
    package = pkgs.gitMinimal;
    lfs.enable = true;

    settings = {
      user = {
        name = "dex";
        email = userEmail;
        signingKey = signingKey;
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "hx";

      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };
      commit.gpgsign = true;
    };

    ignores = [
      ".direnv/"
      "result"
      "*.swp"
    ];
  };
}
