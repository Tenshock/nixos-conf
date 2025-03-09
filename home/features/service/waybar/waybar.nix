{
  home.file.style = {
    source = ./style;
    target = ".config/waybar/style";
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = let
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
            "eDP-1" = [1];
          };
        };
        "clock#date" = {
          "format" = "{:%a %d %b}";
          "tooltip" = false;
          "interval" = 1;
        };
        "clock#time" = {
          "format" = "  {:%H:%M:%S}";
          "tooltip" = false;
          "interval" = 1;
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
        "custom/lock" = {
          "tooltip" = false;
          "on-click" = "hyprlock &";
          "format" = "";
        };
        "custom/shutdown" = {
          "tooltip" = false;
          "on-click" = "/home/cedric/.local/bin/wofi_power_menu.sh &";
          "format" = " ";
        };
      };
      shared-modules = {
        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = false;
          "tooltip" = false;
          "format" = "{icon}";
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
        };
        "memory" = {
          "format" = "  {percentage}%";
          "interval" = 1;
          "states" = {
            "critical" = 80;
          };
        };
        "network" = {
          "format-linked" = "󰛵 {bandwidthDownBits}";
          "format-wifi" = "  {bandwidthDownBits}";
          "format-ethernet" = "󰛳 {bandwidthDownBits}";
          "format-disconnected" = "󰲛  no network";
          "interval" = 1;
          "tooltip" = false;
          "on-click" = "uwsm app -- kitty -e nmtui";
        };
        "bluetooth" = {
          "format" = " {status}";
          "format-off" = "󰂲 {status}";
          "max-length" = 20;
          "format-connected" = " {device_alias}";
          "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
          "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          "on-click" = "uwsm app -- kitty -e bluetui";
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
            "default" = [" " " " " "];
          };
          "format-bluetooth" = "{icon} {volume}%";
          "nospacing" = 1;
          "on-click" = "uwsm app -- kitty -e ncpamixer";
          "tooltip" = false;
        };
        "backlight" = {
          "format" = "{icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" ""];
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
          "format-icons" = [" " " " " " " " " "];
          "tooltip" = false;
        };
      };
    in [
      ({
        "layer" = "top";
        "output" = "eDP-1";
        "name" = "main-bar";
        "modules-left" = [
          "clock#date"
          "clock#time"
          "hyprland/workspaces"
        ];
        "modules-center" = [
          "custom/music"
        ];
        "modules-right" = [
          "network"
          "memory"
          "cpu"
          "bluetooth"
          "pulseaudio"
          "wireplumber"
          "backlight"
          "battery"
        ];
      } // shared-modules // main-monitor-modules)
      ({
        "output" = "!eDP-1";
        "layer" = "top";
        "modules-center" = [
          "hyprland/workspaces"
        ];
        "modules-right" = [
          "network"
          "memory"
          "cpu"
          "bluetooth"
          "pulseaudio"
          "wireplumber"
          "backlight"
          "battery"
        ];
      } // shared-modules)
    ];

    style = ''
      @import "style/mocha.css";
      @import "style/general.css";
      @import "style/main-bar.css";
    '';
  };
}
