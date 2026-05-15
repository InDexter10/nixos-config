{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modes = "drun,window,run";
      terminal = "rio";
      run-command = "{cmd}";
      run-shell-command = "{terminal} -e {cmd}";
    };
  };

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,window,run"; /* BURASI GÜNCELLENDİ */
      font: "JetBrainsMono Nerd Font 12";
      show-icons: true;
      icon-theme: "Papirus";
      drun-display-format: "{name}";
      window-format: "{w} · {c} · {t}";
      display-drun: " ";
      display-window: " ";
      display-run: " "; /* RUN MODU İÇİN ARAYÜZ DÜZELTMESİ EKLENDİ */
      sidebar-mode: false;
      hover-select: false;
    }

    /* Helix Steel — canonical palette */
    * {
      t1:            #0e0e0d;
      t2:            #1d1e1b;
      t3:            #5b5555;
      t4:            #656869;
      t5:            #727b7c;
      t10:           #c3c3bd;
      highlight:     #f23672;
      selection:     #4a9aa6;
      selection-fg:  #080a0b;

      background-color: transparent;
      text-color:        @t10;
      font:              "JetBrainsMono Nerd Font 12";

      margin:  0;
      padding: 0;
      spacing: 0;
    }

    window {
      location:  north;
      anchor:    north;
      y-offset:  0px;

      width:     55%;
      max-width: 1000px;

      background-color: @t1;
      border:           1px solid;
      border-color:     @t3;
      border-radius:    12px;
    }

    mainbox {
      padding:  12px;
      children: [ inputbar, message, listview ];
    }

    inputbar {
      background-color: @t2;
      border:           1px solid;
      border-color:     @t3;
      border-radius:    8px;
      padding:          8px 12px;
      spacing:          12px;
      children:         [ prompt, entry ];
    }

    prompt {
      text-color: @highlight;
      font:       "JetBrainsMono Nerd Font Bold 12";
    }

    entry {
      text-color:        @t10;
      placeholder:       "Search...";
      placeholder-color: @t3;
    }

    message {
      background-color: @t2;
      border:           1px solid;
      border-color:     @t3;
      border-radius:    8px;
      padding:          8px 12px;
      margin:           12px 0px 0px 0px;
    }

    textbox {
      text-color: @t10;
    }

    error-message {
      background-color: @t1;
      border:           1px solid;
      border-color:     @highlight;
      border-radius:    8px;
      padding:          8px 12px;
      text-color:       @highlight;
    }

    listview {
      lines:        8;
      columns:      1;
      scrollbar:    false;
      spacing:      4px;
      margin:       12px 0px 0px 0px;
      fixed-height: false;
      cycle:        true;
    }

    element {
      padding:       8px 12px;
      border-radius: 6px;
      spacing:       8px;
    }

    element normal.normal,
    element alternate.normal {
      background-color: transparent;
      text-color:       @t4;
    }

    element selected.normal {
      background-color: @selection;
      text-color:       @selection-fg;
    }

    element-text {
      vertical-align: 0.5;
      text-color:     inherit;
    }

    element-icon {
      size:    24px;
      padding: 0px 12px 0px 0px;
    }
  '';
}
