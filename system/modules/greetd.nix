{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session = {
      # --config acikca veriliyor: tuigreet o yolu kendiliginden de arar ama
      # dosya okunamazsa sessizce varsayilana dusmek yerine belli olsun.
      command = "${pkgs.tuigreet}/bin/tuigreet --config /etc/tuigreet/config.toml --cmd labwc";
      user = "greeter";
    };
  };

  # tuigreet 0.11 TOML semasi kati degil: taninmayan anahtar hata vermez,
  # sessizce yok sayilir - buradaki bir yazim hatasi giris ekranini kilitlemez.
  environment.etc."tuigreet/config.toml".text = ''
    [display]
    show_time  = false
    show_title = false
    issue      = false

    [layout]
    width             = 64
    window_padding    = 2
    container_padding = 2
    prompt_padding    = 1

    [layout.widgets]
    time_position   = "hidden"
    status_position = "bottom"

    [remember]
    username = true
    session  = false

    # Parola yazarken hicbir geri bildirim yok; "characters" modu parolanin
    # uzunlugunu yanindakine sizdirir (os/sudo-rs.nix'teki !pwfeedback ile ayni karar).
    [secret]
    mode = "hidden"

    [keybindings]
    command  = 2
    sessions = 3
    power    = 12

    [power]
    shutdown   = "systemctl poweroff"
    reboot     = "systemctl reboot"
    use_setsid = true

    # Gecerli isimler: black red green yellow blue magenta cyan white
    # ve bright-* varyantlari.
    [theme]
    border    = "cyan"
    title     = "cyan"
    text      = "white"
    time      = "bright-blue"
    container = "black"
    greet     = "cyan"
    prompt    = "white"
    input     = "white"
    action    = "bright-blue"
    button    = "bright-red"

    # Kapatmak icin: kind = "none"
    # fps 20: N4000'de giris ekranini bosuna dondurmeye gerek yok.
    [background]
    kind = "matrix"
    fps  = 20

    [background.matrix]
    head_color    = "#B2EBF2"
    bright_color  = "#26C6DA"
    dim_color     = "#00494F"
    min_length    = 6
    max_length    = 16
    min_speed     = 0.25
    max_speed     = 0.80
    mutate_chance = 0.01
  '';

  # --remember son kullanici adini buraya yazar.
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0700 greeter greeter - -"
  ];
}
