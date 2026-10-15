{ ... }:

{
  programs.fish = {
    enable = true;

    generateCompletions = false;

    interactiveShellInit = ''
      set -g fish_greeting
    '';

    shellAbbrs = {
      h = "cd ~";
      b = "cd ~/Books";
      bb = "cd ~/Books && yazi";

      d = "cd ~/Downloads";
      dd = "cd ~/Documents && yazi";
      n = "cd ~/.config/nixconf";
      nn = "cd ~/.config/nixconf && claude -r";

      "..." = "cd ../..";
      "...." = "cd ../../..";

      homeup = "home-manager switch --flake ~/.config/nixconf#dex";
      sysup = "sudo nixos-rebuild switch --flake ~/.config/nixconf#msi";
      lg = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";

      # Satir ortasinda da acilir.
      G = {
        position = "anywhere";
        expansion = "| grep -i";
      };
      E = {
        position = "anywhere";
        expansion = "| less -R";
      };
      J = {
        position = "anywhere";
        expansion = "| jq";
      };
      NE = {
        position = "anywhere";
        expansion = "2>/dev/null";
      };
    };
  };

  xdg.cacheFile."fish/generated_completions/.keep".text = "";
}
