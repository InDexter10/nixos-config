{ ... }:

{
  programs.cava = {
    enable = true;

    settings = {
      input.method = "pipewire";

      # Sutunlarin altinda her sutunun alt frekans siniri (Hz) gosterilir.
      output.xaxis = "frequency";

      # cava hex rengi tirnak icinde bekler.
      color.foreground = "'#9ac5ba'";
    };
  };
}
