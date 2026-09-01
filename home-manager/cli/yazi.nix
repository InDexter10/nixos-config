{ pkgs, ... }:

# Gezinme katmani. Enter/o -> handlr uzerinden sistem uygulamasi (mime
# eslesmeleri wm/etc/mime.nix'te, burada TEKRARLANMAZ), metin dosyasi -> helix.
#
# GORSEL ONIZLEME YOK: resim/PDF/video onizleyicileri terminalde bir grafik
# protokolu ister (Kitty graphics, Sixel, iTerm2) ve alacritty 0.17'de
# bunlarin hicbiri yok. Ilgili ayarlar (image_filter, image_quality,
# image_delay) bu yuzden kaldirildi - etkileri yoktu. Cozum bir ayar degil,
# terminal degisikligidir. Metin tabanli onizlemeler tam calisiyor.

{
  programs.yazi = {
    enable = true;

    enableZshIntegration = true;
    shellWrapperName = "y"; # cikista dizin degistirir

    # Yalnizca yazi'nin PATH'ine eklenir. Her biri yazi'nin HAZIR GELEN bir
    # tusunu calisir hale getirir: fd -> "s", fzf -> "<C-s>", zoxide -> "z",
    # unar -> arsiv onizlemesi. ("S" icin gereken ripgrep cli/default.nix'te.)
    # NOT: ayni ucu cli/zsh.nix kabuga da aciyor; store'da tek kopya.
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

        sort_by = "natural"; # 1.md < 2.md < 10.md
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;

        show_hidden = true;
        show_symlink = true;

        # "size" olmaz: yazi boyutu yalnizca sort_by = "size" iken hesaplar,
        # aksi halde sutun bos kalir.
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

      # Mime tabanli: uzanti listesi (*.nix, *.toml...) gereksizdi, hepsi
      # zaten text/* olarak taniniyor.
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
