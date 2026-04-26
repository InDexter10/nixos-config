{ pkgs, ... }:

{
  # Rofi'yi Wayland uyumlu paketiyle aktifleştiriyoruz
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
  };

  # Rofi'nin ana yapılandırması ve Steel teması
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,window,run";
      font: "JetBrainsMono Nerd Font 12";
      show-icons: true;
      icon-theme: "Papirus"; /* Sisteminde yüklü ikon temasını buraya yazabilirsin */
      display-drun: " "; 
      display-window: " ";
      display-run: " ";
      drun-display-format: "{name}";
      window-format: "{w} · {c} · {t}";
      
      /* labwc pencerelerini tanıyabilmesi için */
      window-command: "wtype -M alt -k tab -m alt"; 
    }

    /* Orijinal Helix Steel Paleti Entegrasyonu */
    * {
      t1:  #0e0e0d; /* ui.background bg / ui.statusline bg */
      t2:  #1d1e1b; /* ui.background bg (alt) / ui.gutter bg */
      t3:  #5b5555; /* ui.background.separator / ui.linenr */
      t4:  #656869; /* ui.text */
      t10: #c3c3bd; /* Orijinal temadaki function / light text */
      
      selection-bg: #4a9aa6; /* ui.selection bg */
      selection-fg: #080a0b; /* ui.selection fg */
      
      highlight: #f23672; /* ui.cursor.match / vurgular */

      background-color: transparent;
      text-color: @t4;
      margin:  0;
      padding: 0;
      spacing: 0;
    }

    /* Ekranın üst-ortasında, Waybar'ın altında konumlandırma */
    window {
      location: north;
      anchor: north;
      /* Waybar (34px) + margin (-8 üst, 10 alt) = ~44px boşluk bırakarak tam alta hizalar */
      y-offset: 44px; 
      width: 500px;
      
      background-color: @t1;
      border: 1px solid;
      border-color: @t3;
      border-radius: 12px;
    }

    mainbox {
      padding: 12px;
      children: [inputbar, message, listview];
    }

    inputbar {
      background-color: @t2;
      border: 1px solid;
      border-color: @t3;
      border-radius: 8px;
      padding: 8px 12px;
      spacing: 12px;
      children: [prompt, entry];
    }

    prompt {
      text-color: @highlight;
      font: "JetBrainsMono Nerd Font Bold 12";
    }

    entry {
      text-color: @t10;
      placeholder: "Ara...";
      placeholder-color: @t3;
    }

    listview {
      lines: 8;
      columns: 1;
      scrollbar: false;
      spacing: 4px;
      margin: 12px 0px 0px 0px;
    }

    element {
      padding: 8px 12px;
      border-radius: 6px;
    }

    element normal.normal {
      background-color: transparent;
      text-color: @t4;
    }

    element alternate.normal {
      background-color: transparent;
      text-color: @t4;
    }

    element selected.normal {
      background-color: @selection-bg;
      text-color: @selection-fg;
    }

    element-text {
      vertical-align: 0.5;
      text-color: inherit;
    }

    element-icon {
      size: 24px;
      padding: 0px 12px 0px 0px;
    }
  '';
}
