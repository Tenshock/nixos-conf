{
  wayland.windowManager.hyprland.settings = {
    general = {
      border_size = 1;
      gaps_in = 3;
      gaps_out = 6;
      "col.active_border" = "rgba(e5c76baa)";
      "col.inactive_border" = "rgba(59595900)";
      layout = "dwindle";
      resize_on_border = false;
    };

    decoration = {
      active_opacity = 0.85;
      inactive_opacity = 0.85;

      rounding = 12;

      blur = {
        enabled = true;
        size = 3;
        passes = 1;

        vibrancy = 0.1696;
      };

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
    };
  };
}
