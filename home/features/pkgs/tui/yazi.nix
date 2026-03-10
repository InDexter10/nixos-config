{ pkgs, ... }:

let
  yaziConfig = ''
    [mgr]
    ratio          = [1, 4, 3]   
    sort_by        = "natural"   
    sort_sensitive = false       
    sort_reverse   = false
    sort_dir_first = true        
    show_hidden    = true        
    show_symlink   = true        
    linemode       = "size"      

    [preview]
    tab_size       = 2
    max_width      = 600
    max_height     = 900
    cache_dir      = ""
    image_filter   = "lanczos3"  
    image_quality  = 90
    sixel_fraction = 15

    [opener]
    edit = [
      { run = 'hx "$@"', block = true, desc = "Helix" }
    ]

    system = [
      { run = 'handlr open "$@"', orphan = true, desc = "Sistem" }
    ]

    [open]
    rules = [
      # 1. Metin Dosyaları -> Helix
      { mime = "text/*", use = "edit" },
      { mime = "application/json", use = "edit" },
      { mime = "application/javascript", use = "edit" },
      { mime = "application/x-shellscript", use = "edit" },
      { name = "*.nix", use = "edit" },
      { name = "*.md", use = "edit" },
      { name = "*.conf", use = "edit" },
      { name = "*.toml", use = "edit" },

      { name = "*", use = "system" }
    ]

    [plugin]
    # Video dosyaları için ffmpeg tetikleyicilerini ezip, sadece temel "file" (dosya bilgisi okuyucu) eklentisine yönlendiriyoruz.
    prepend_previewers = [
      { mime = "video/*", run = "file" }
    ]
    prepend_preloaders = [
      { mime = "video/*", run = "noop" }
    ]
  '';

in
{
  home.packages = [ pkgs.yazi ];

  xdg.configFile."yazi/yazi.toml".text = yaziConfig;

  programs.zsh.initContent = ''
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
  '';
}
