{
  imports = [ ./widget/gsimplecal.nix ];

  home.file.".config/waybar/style".source = ./style;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings =
      let
        main-monitor-modules = {
          "hyprland/workspaces" = {
            "disable-scroll" = true;
            "all-outputs" = false;
            "tooltip" = false;
            "format" = "{icon}";
            "format-icons" = {
              "1" = "  ";
            };
            "persistent-workspaces" = {
              "eDP-1" = [ 1 ];
            };
          };
          "clock#date" = {
            "format" = "{:%a %d %b}";
            "tooltip" = false;
            "interval" = 1;
            "on-click" = "uwsm app -- gsimplecal";
          };
          "clock#time" = {
            "format" = "  {:%H:%M:%S}";
            "tooltip" = false;
            "interval" = 1;
            "on-click" = "uwsm app -- gsimplecal";
          };
          "custom/music" = {
            "format" = "  {}";
            "escape" = true;
            "interval" = 1;
            "tooltip" = false;
            "exec" = "playerctl metadata --format='{{ title }}'";
            "on-click" = "playerctl play-pause";
            "max-length" = 50;
          };
        };
        shared-modules = {
          "hyprland/workspaces" = {
            "disable-scroll" = true;
            "all-outputs" = false;
            "tooltip" = false;
            "format" = "{icon}";
          };
          "custom/left-spacer" = {
            "tooltip" = false;
            "format" = " ";
          };
          "cpu" = {
            "interval" = 1;
            "format" = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}";
            "format-icons" = [
              "<span color='#74c7ec'>▁</span>" # sapphire
              "<span color='#89dceb'>▂</span>" # sky
              "<span color='#94e2d5'>▃</span>" # teal
              "<span color='#a6e3a1'>▄</span>" # green
              "<span color='#f9e2af'>▅</span>" # yellow
              "<span color='#fab387'>▆</span>" # peach
              "<span color='#eba0ac'>▇</span>" # maroon
              "<span color='#f38ba8'>█</span>" # red
            ];
            "states" = {
              "critical" = 90;
            };
            "on-click" = "uwsm app -- kitty -e btop";
          };
          "memory" = {
            "format" = "  {percentage}%";
            "interval" = 1;
            "states" = {
              "critical" = 80;
            };
            "on-click" = "uwsm app -- kitty -e btop";
          };
          "network" = {
            "format-linked" = "󰛵 {bandwidthDownOctets}";
            "format-wifi" = "  {signalStrength}% {bandwidthDownOctets}";
            "format-ethernet" = "󰛳 {bandwidthDownOctets}";
            "format-disconnected" = "󰲛  no network";
            "interval" = 1;
            "tooltip" = false;
            "on-click" = "uwsm app -- kitty -e nmtui";
          };
          "tray" = {
            "icon-size" = 16;
            "spacing" = 6;
            "icons" = {
              "1Password_status_icon_1" = "${./style/icons/1password-lock-red.png}";
              "vesktop" = "${./style/icons/vesktop-brand-discord-red.png}";
              "Vesktop" = "${./style/icons/vesktop-brand-discord-red.png}";
              "beeper" = "${./style/icons/beeper-message-circle-red.png}";
              "Beeper_status_icon_1" = "${./style/icons/beeper-message-circle-red.png}";
              "beepertexts" = "${./style/icons/beeper-message-circle-red.png}";
              "Beeper" = "${./style/icons/beeper-message-circle-red.png}";
              "easyeffects" = "${./style/icons/easyeffects-adjustments-red.png}";
              "mattermost" = "${./style/icons/mattermost-red.png}";
              "mattermost-desktop" = "${./style/icons/mattermost-red.png}";
              "Mattermost" = "${./style/icons/mattermost-red.png}";
              "slack" = "${./style/icons/slack-red.png}";
              "Slack" = "${./style/icons/slack-red.png}";
              "slack_status_icon_1" = "${./style/icons/slack-red.png}";
              "Slack_status_icon_1" = "${./style/icons/slack-red.png}";
              "steam" = "${./style/icons/steam-brand-red.png}";
              "Steam" = "${./style/icons/steam-brand-red.png}";
              "vlc" = "${./style/icons/vlc-red.png}";
              "VLC media player" = "${./style/icons/vlc-red.png}";
            };
          };
          "bluetooth" = {
            "format" = " {status}";
            "format-off" = "󰂲 {status}";
            "max-length" = 20;
            "format-connected" = " {device_alias}";
            "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
            "tooltip-format" = ''
              {controller_alias}	{controller_address}

              {num_connections} connected'';
            "tooltip-format-connected" = ''
              {controller_alias}	{controller_address}

              {num_connections} connected

              {device_enumerate}'';
            "tooltip-format-enumerate-connected" = "{device_alias}	{device_address}";
            "tooltip-format-enumerate-connected-battery" =
              "{device_alias}	{device_address}	{device_battery_percentage}%";
            "on-click" = "uwsm app -- kitty -e bluetui";
          };
          "power-profiles-daemon" = {
            "format" = "{icon}";
            "tooltip" = true;
            "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
            "format-icons" = {
              "default" = " ";
              "performance" = " ";
              "balanced" = " ";
              "power-saver" = " ";
            };
          };
          "pulseaudio" = {
            "format-source" = "";
            "format-source-muted" = " ";
            "format" = "{format_source}";
            "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };
          "wireplumber" = {
            "scroll-step" = 5;
            "max-volume" = 150.0;
            "format" = "{icon} {volume}%";
            "format-muted" = "  {volume}%";
            "format-icons" = {
              "default" = [
                " "
                " "
                " "
              ];
            };
            "format-bluetooth" = "{icon} {volume}%";
            "nospacing" = 1;
            "on-click" = "uwsm app -- kitty -e ncpamixer";
            "tooltip" = false;
          };
          "backlight" = {
            "format" = "{icon}";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "battery" = {
            "interval" = 1;
            "states" = {
              "warning" = 20;
              "critical" = 10;
            };
            "format" = "{icon} {capacity}%";
            "format-charging" = "󰂄 {capacity}%";
            "format-plugged" = " {capacity}%";
            "format-icons" = [
              " "
              " "
              " "
              " "
              " "
            ];
            "tooltip" = false;
          };
        };
      in
      [
        (
          {
            "layer" = "top";
            "output" = "eDP-1";
            "name" = "main-bar";
            "modules-left" = [
              "clock#date"
              "clock#time"
              "hyprland/workspaces"
            ];
            "modules-center" = [ "custom/music" ];
            "modules-right" = [
              "custom/left-spacer"
              "tray"
              "network"
              "memory"
              "cpu"
              "power-profiles-daemon"
              "bluetooth"
              "pulseaudio"
              "wireplumber"
              "backlight"
              "battery"
            ];
          }
          // shared-modules
          // main-monitor-modules
        )
        (
          {
            "output" = "!eDP-1";
            "layer" = "top";
            "modules-center" = [ "hyprland/workspaces" ];
            "modules-right" = [
              "custom/left-spacer"
              "tray"
              "network"
              "memory"
              "cpu"
              "power-profiles-daemon"
              "bluetooth"
              "pulseaudio"
              "wireplumber"
              "backlight"
              "battery"
            ];
          }
          // shared-modules
        )
      ];

    style = ''
      @import "style/mocha.css";
      @import "style/general.css";
      @import "style/main-bar.css";
    '';
  };
}
