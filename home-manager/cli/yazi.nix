{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    enableZshIntegration = true;
    shellWrapperName = "y";

    extraPackages = with pkgs; [
      fd
      fzf
      zoxide
      unar
    ];

    settings = {
      mgr = {
        ratio = [
          1
          3
          3
        ];

        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;

        show_hidden = true;
        show_symlink = true;

        linemode = "mtime";

        scrolloff = 5;
      };

      preview.tab_size = 2;

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
          mime = "application/{json,x-ndjson,javascript,x-shellscript,xml,toml,yaml}";
          use = "edit";
        }
        {
          mime = "inode/x-empty";
          use = "edit";
        }
        {
          url = "*";
          use = "system";
        }
      ];
    };
  };
}
