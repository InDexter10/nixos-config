{
  pkgs,
  lib,
  config,
  ...
}:

{

  programs.fish = {
    enable = true;

    plugins = [

      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }

      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
    ];

    shellAliases = {

      sysup = "sudo nixos-rebuild switch --flake ~/nixos-config#msi-aio";
      homeup = "home-manager switch --flake ~/nixos-config#dx5";

    };

    functions = {
      fish_greeting = "";
    };

    interactiveShellInit = ''
      starship init fish | source


      direnv hook fish | source

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
