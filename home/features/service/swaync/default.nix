let
  colors = import ../../../theme/colors.nix;
in
{
  services.swaync = {
    enable = true;
    settings = {
      ignore-gtk-theme = true;
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "overlay";
      layer-shell = true;
      cssPriority = "user";

      control-center-width = 380;
      control-center-height = 860;
      control-center-margin-top = 2;
      control-center-margin-bottom = 2;
      control-center-margin-right = 1;
      control-center-margin-left = 0;

      notification-window-width = 400;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;
      notification-2fa-action = true;
      notification-inline-replies = false;

      timeout = 4;
      timeout-low = 2;
      timeout-critical = 6;

      fit-to-screen = false;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = false;
      script-fail-notify = true;

      widgets = [
        "label"
        "title"
        "dnd"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = " 󰎟 ";
        };
        dnd.text = "Do not disturb";
        label = {
          max-lines = 1;
          text = " ";
        };
      };
    };

    style =
      builtins.replaceStrings
        [
          "__FOREGROUND__"
          "__BACKGROUND__"
          "__BACKGROUND_SEC__"
          "__HYPRLAND_BORDER__"
          "__COLOR1__"
          "__COLOR2__"
          "__COLOR3__"
          "__COLOR5__"
          "__COLOR6__"
        ]
        [
          colors.catppuccin.text
          colors.catppuccin.base
          colors.catppuccin.surface0
          colors.hyprland.activeBorderCss
          colors.catppuccin.surface1
          colors.catppuccin.red
          colors.catppuccin.yellow
          colors.catppuccin.blue
          colors.catppuccin.teal
        ]
        (builtins.readFile ./style.css);
  };
}
