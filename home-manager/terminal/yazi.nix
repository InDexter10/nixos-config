{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    # nixpkgs varsayilanindan fzf, zoxide ve chafa cikarildi. ffmpeg,
    # imagemagick ve 7zz de yok: guvenilmeyen dosyalari imlec ustune gelince
    # ayristirirlar.
    package = pkgs.yazi.override {
      optionalDeps = with pkgs; [
        jq
        poppler-utils
        fd
        ripgrep
        resvg
      ];
    };

    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        ratio = [
          1
          3
          3
        ];
        sort_by = "natural";
        show_hidden = true;
        linemode = "mtime";
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
        firefox = [
          {
            run = "flatpak run --file-forwarding org.mozilla.firefox @@ %s @@";
            orphan = true;
            desc = "Firefox";
          }
        ];
      };

      # MIME turleri x- oneki atilmis halde eslesir (inode/x-empty -> inode/empty).
      open.rules = [
        {
          mime = "text/*";
          use = "edit";
        }
        {
          mime = "application/{json,ndjson,javascript,shellscript,xml,toml,yaml}";
          use = "edit";
        }
        {
          mime = "inode/empty";
          use = "edit";
        }
        {
          mime = "application/pdf";
          use = [
            "system"
            "firefox"
          ];
        }
        {
          url = "*";
          use = "system";
        }
      ];

      # Asagidaki turlerin varsayilan eklentileri ffmpeg, magick veya 7zz
      # cagirir. "file" yalnizca dosya turunu gosterir, "noop" hicbir sey yapmaz.
      plugin = {
        prepend_previewers = [
          {
            mime = "image/{avif,hei?,jxl}";
            run = "file";
          }
          {
            mime = "{video,font}/*";
            run = "file";
          }
          {
            mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*,debian*-package,redhat-package-manager,rpm,android.package-archive,iso9660-image,qemu-disk,ms-wim,apple-diskimage,virtualbox-vhd,virtualbox-vhdx,ms-opentype}";
            run = "file";
          }
          {
            url = "*.{AppImage,appimage,img,fat,ext,ext2,ext3,ext4,squashfs,ntfs,hfs,hfsx}";
            run = "file";
          }
        ];
        prepend_preloaders = [
          {
            mime = "image/{avif,hei?,jxl}";
            run = "noop";
          }
          {
            mime = "{video,font}/*";
            run = "noop";
          }
          {
            mime = "application/ms-opentype";
            run = "noop";
          }
        ];
        prepend_spotters = [
          {
            mime = "image/{avif,hei?,jxl}";
            run = "file";
          }
          {
            mime = "video/*";
            run = "file";
          }
        ];
      };
    };
  };
}
