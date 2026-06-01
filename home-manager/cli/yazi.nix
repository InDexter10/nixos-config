{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    enableZshIntegration = true;
    shellWrapperName = "y";

    extraPackages = with pkgs; [
      ffmpegthumbnailer # video küçük resimleri
      ueberzugpp
    ];

    settings = {
      mgr = {
        ratio = [
          1
          3
          3
        ];
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        show_hidden = true;
        show_symlink = true;
        linemode = "size";
      };

      preview = {
        tab_size = 2;
        image_delay = 50; # hızlı kaydırmada önizleme lag'ini azaltır
        image_filter = "lanczos3"; # en yüksek kalite ölçekleme
        image_quality = 90;
      };

      opener = {
        edit = [
          {
            run = "hx %s";
            block = true;
            desc = "Helix";
          }
        ];
        system = [
          {
            run = "handlr open %s";
            orphan = true;
            desc = "Sistem";
          }
        ];
      };

      open.rules = [
        {
          mime = "text/*";
          use = "edit";
        }
        {
          mime = "application/json";
          use = "edit";
        }
        {
          mime = "application/javascript";
          use = "edit";
        }
        {
          mime = "application/x-shellscript";
          use = "edit";
        }
        {
          name = "*.nix";
          use = "edit";
        }
        {
          name = "*.md";
          use = "edit";
        }
        {
          name = "*.conf";
          use = "edit";
        }
        {
          name = "*.toml";
          use = "edit";
        }
        {
          name = "*";
          use = "system";
        } # catchall — en sonda
      ];
    };
  };
}
