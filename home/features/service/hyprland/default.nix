{ pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/hyprland/b57375545f5da1f7790341905d1049b1873a8bb3/themes/mocha.conf";
    sha256 = "sha256-SxVNvZZjfuPA2yB9xA0EHHEnE9eIQJAFVBIUuDiSIxQ=";
  };
in
{
  catppuccin.hyprland.enable = true;

  home = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    file."${config.xdg.configHome}/hypr/mocha.conf".source = mochaTheme;
  };

  imports = [
    ./animations.nix
    ./bindings.nix
    ./ui.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # Necessary for UWSM integration. See nixos/hyprland.nix

    settings = {
      source = [ "~/.config/hypr/mocha.conf" ];

      # Apps
      "$audioManager" = "uwsm app -- $(kitty -e ncpamixer)";
      "$bluetoothManager" = "uwsm app -- $(kitty -e bluetui)";
      "$browser" = "uwsm app -- zen-twilight";
      "$cbonsai" = "uwsm app -- $(kitty -e cbonsai --live --time 0,2)";
      "$fileManager" = "uwsm app -- dolphin";
      "$hyprlock" = "uwsm app -- hyprlock";
      "$networkManager" = "uwsm app -- $(kitty -e nmtui)";
      "$statusbar" = "uwsm app -- waybar";
      "$teams" = "uwsm app -- teams-for-linux";
      "$terminal" = "uwsm app -- kitty";
      "$obsidian" = "uwsm app -- obsidian";

      exec-once = [ "[workspace 1 silent] $terminal" ];

      dwindle = {
        preserve_split = true;
      };

      gesture = [
        "3, horizontal, workspace"
        "4, horizontal, workspace"
      ];

      input = {
        kb_layout = "fr";
        follow_mouse = 1;
        sensitivity = 0.2;

        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.35;
        };
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      monitor = [
        "eDP-1,2880x1920@120,auto,1.6"
        ",preferred,auto,auto"
      ];

      workspace = [ "1, monitor:eDP-1" ];

      windowrule = [
        "suppress_event maximize, match:class .*"

        "no_initial_focus on, focus_on_activate off, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"

        "stay_focused on, match:class wofi"
      ];
    };
  };
}
