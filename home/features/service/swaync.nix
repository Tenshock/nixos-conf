let
  colors = import ../../theme/colors.nix;
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

    style = ''
      @define-color foreground     ${colors.catppuccin.text};
      @define-color background     ${colors.catppuccin.base};
      @define-color background-sec ${colors.catppuccin.surface0};
      @define-color hyprland-border ${colors.hyprland.activeBorderCss};
      @define-color color1         ${colors.catppuccin.surface1};
      @define-color color2         ${colors.catppuccin.red};
      @define-color color3         ${colors.catppuccin.yellow};
      @define-color color5         ${colors.catppuccin.blue};
      @define-color color6         ${colors.catppuccin.teal};

      @define-color text            @foreground;
      @define-color background-alt  @color1;
      @define-color selected        @hyprland-border;
      @define-color hover           @color5;
      @define-color urgent          @color2;

      * {
        color: @text;
        all: unset;
        font-size: 14px;
        font-family: "JetBrains Mono Nerd Font 10";
        transition: 200ms;
      }

      .notification-row {
        outline: none;
        margin: 0;
        padding: 0px;
      }

      .floating-notifications.background .notification-row .notification-background {
        background: alpha(@background, .55);
        box-shadow: 0 0 8px 0 rgba(0,0,0,.6);
        border: 1px solid @selected;
        border-radius: 24px;
        margin: 5px;
        padding: 0;
      }

      .floating-notifications.background .notification-row .notification-background .notification {
        border-radius: 12px;
      }

      .floating-notifications.background .notification-row .notification-background .notification.critical {
        border: 2px solid @urgent;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content {
        margin: 14px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
        background-color: @background-alt;
        margin: 6px;
        border: 1px solid transparent;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action button,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * button.notification-action {
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: @hover;
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
        border: 1px solid @selected;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover button,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action button:hover {
        background-color: @hover;
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
        color: @text;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: @selected;
        color: @text;
      }

      .notification-action:hover,
      button.notification-action:hover,
      button.notification-action:hover label {
        background: @selected;
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
        color: @text;
      }

      .notification-action:hover {
        border: 1px solid @selected;
        border-radius: 8px;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:first-child,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:first-child:hover,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * button.notification-action:first-child,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * button.notification-action:first-child:hover {
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:last-child,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:last-child:hover,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * button.notification-action:last-child,
      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * button.notification-action:last-child:hover {
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
      }

      .image {
        margin: 10px 20px 10px 0px;
      }

      .summary {
        font-weight: 800;
        font-size: 1rem;
        margin-bottom: 2px;
      }

      .body {
        font-size: 0.8rem;
      }

      .floating-notifications.background .notification-row .notification-background .close-button {
        margin: 6px;
        padding: 2px;
        border-radius: 6px;
        background-color: transparent;
        border: 1px solid transparent;
      }

      .floating-notifications.background .notification-row .notification-background .close-button:hover {
        background-color: @selected;
      }

      .floating-notifications.background .notification-row .notification-background .close-button:active {
        background-color: @selected;
        color: @background;
      }

      .notification.critical progress {
        background-color: @selected;
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: @selected;
      }

      @define-color background-alt alpha(@color1, .4);
      @define-color selected       @hyprland-border;
      @define-color hover          alpha(@selected, .4);
      @define-color urgent         @color2;

      .blank-window {
        background: transparent;
      }

      .control-center {
        background: alpha(@background, .55);
        border-radius: 24px;
        border: 1px solid @selected;
        box-shadow: 0 0 10px 0 rgba(0,0,0,.6);
        margin: 18px;
        padding: 12px;
      }

      .control-center .notification-row .notification-background,
      .control-center .notification-row .notification-background .notification.critical {
        background-color: @background-alt;
        border-radius: 16px;
        margin: 4px 0px;
        padding: 4px;
      }

      .control-center .notification-row .notification-background .notification.critical {
        color: @urgent;
      }

      .control-center .notification-row .notification-background .notification .notification-content {
        margin: 6px;
        padding: 8px 6px 2px 2px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
        background: alpha(@selected, .6);
        color: @text;
        border-radius: 12px;
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
        border-bottom-right-radius: 12px;
        border-bottom-left-radius: 12px;
        margin: 0;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action button,
      .control-center .notification-row .notification-background .notification > *:last-child > * button.notification-action {
        border-radius: 12px;
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
        border-bottom-right-radius: 12px;
        border-bottom-left-radius: 12px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background: @selected;
        border-radius: 12px;
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
        border-bottom-right-radius: 12px;
        border-bottom-left-radius: 12px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover button,
      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action button:hover {
        background: @selected;
        border-radius: 12px;
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
        border-bottom-right-radius: 12px;
        border-bottom-left-radius: 12px;
        color: @text;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: @selected;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:first-child,
      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:first-child:hover,
      .control-center .notification-row .notification-background .notification > *:last-child > * button.notification-action:first-child,
      .control-center .notification-row .notification-background .notification > *:last-child > * button.notification-action:first-child:hover {
        border-top-left-radius: 12px;
        border-bottom-left-radius: 12px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:last-child,
      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:last-child:hover,
      .control-center .notification-row .notification-background .notification > *:last-child > * button.notification-action:last-child,
      .control-center .notification-row .notification-background .notification > *:last-child > * button.notification-action:last-child:hover {
        border-top-right-radius: 12px;
        border-bottom-right-radius: 12px;
      }

      .control-center .notification-row .notification-background .close-button {
        background: transparent;
        border-radius: 6px;
        color: @text;
        margin: 0px;
        padding: 4px;
      }

      .control-center .notification-row .notification-background .close-button:hover {
        background-color: @selected;
      }

      .control-center .notification-row .notification-background .close-button:active {
        background-color: @selected;
      }

      progressbar,
      progress,
      trough {
        border-radius: 12px;
      }

      progressbar {
        background-color: rgba(255,255,255,.1);
      }

      .notification-group {
        margin: 2px 8px 2px 8px;
      }

      .notification-group-headers {
        font-weight: bold;
        font-size: 1.25rem;
        color: @text;
        letter-spacing: 2px;
      }

      .notification-group-icon {
        color: @text;
      }

      .notification-group-collapse-button,
      .notification-group-close-all-button {
        background: transparent;
        color: @text;
        margin: 4px;
        border-radius: 6px;
        padding: 4px;
      }

      .notification-group-collapse-button:hover,
      .notification-group-close-all-button:hover {
        background: @hover;
      }

      .widget-title {
        font-size: 1.2em;
        margin: 6px;
      }

      .widget-title button {
        background: @background-alt;
        border-radius: 6px;
        padding: 4px 16px;
      }

      .widget-title button:hover {
        background-color: @hover;
      }

      .widget-title button:active {
        background-color: @selected;
      }

      .widget-dnd {
        margin: 6px;
        font-size: 1.2rem;
      }

      .widget-dnd > switch {
        background: @background-alt;
        font-size: initial;
        border-radius: 8px;
        box-shadow: none;
        padding: 2px;
      }

      .widget-dnd > switch:hover {
        background: @hover;
      }

      .widget-dnd > switch:checked {
        background: @selected;
      }

      .widget-dnd > switch:checked:hover {
        background: @hover;
      }

      .widget-dnd > switch slider {
        background: @text;
        border-radius: 6px;
      }
    '';
  };
}
