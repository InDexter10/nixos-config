{ ... }:

# Super+N ile acilip kapatilir (wm/labwc/config/rc.xml).
{
  services.wlsunset = {
    enable = true;

    # Gun dogumu/batimi bu koordinattan hesaplanir.
    latitude = "39.9";
    longitude = "32.8";

    temperature = {
      day = 4500;
      night = 4000;
    };
  };
}
