let
  colors = import ../../../theme/colors.nix;
in
{
  wayland.windowManager.hyprland.settings = {
    layer_rule = [
      {
        match.namespace = "swaync-control-center";
        blur = true;
        ignore_alpha = 0.2;
      }
      {
        match.namespace = "swaync-notification-window";
        blur = true;
        ignore_alpha = 0.2;
      }
    ];

    config = {
      general = {
        border_size = 1;
        gaps_in = 3;
        gaps_out = 6;
        "col.active_border" = colors.hyprland.activeBorder;
        "col.inactive_border" = colors.hyprland.inactiveBorder;
        layout = "dwindle";
        resize_on_border = false;
      };

      decoration = {
        rounding = 12;

        blur = {
          enabled = true;
          size = 4;
          passes = 2;

          vibrancy = 0.1696;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = colors.hyprland.shadow;
        };
      };
    };
  };
}
