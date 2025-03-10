{pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/hyprland/b57375545f5da1f7790341905d1049b1873a8bb3/themes/mocha.conf";
    sha256 = "sha256-SxVNvZZjfuPA2yB9xA0EHHEnE9eIQJAFVBIUuDiSIxQ=";
  };
in {
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
      source = [
        "$XDG_CONFIG_HOME/hypr/mocha.conf"
      ];

      # Apps
      "$audioManager" = "uwsm app -- $(kitty -e ncpamixer)";
      "$bluetoothManager" = "uwsm app -- $(kitty -e bluetui)";
      "$browser" = "uwsm app -- librewolf";
      "$cbonsai" = "uwsm app -- $(kitty -e cbonsai --live --time 0,2)";
      "$fileManager" = "uwsm app -- $(kitty -e yazi)";
      "$hyprlock" = "uwsm app -- hyprlock";
      "$networkManager" = "uwsm app -- $(kitty -e nmtui)";
      "$statusbar" = "uwsm app -- waybar";
      "$teams" = "uwsm app -- teams-for-linux";
      "$terminal" = "uwsm app -- kitty";
      "$obsidian" = "uwsm app -- obsidian";

      exec-once = [
        "[workspace 1 silent] $terminal"
      ];

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };

      input = {
        kb_layout = "fr";
        follow_mouse = 1;
        sensitivity = 0;

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
        "eDP-1,1920x1080@60,auto,1"
        ",preferred,auto,auto"
      ];

      workspace = [
        "1, monitor:eDP-1"
      ];

      windowrulev2 = [
        # Ignore maximize requests from apps. You'll probably like this.
        "suppressevent maximize, class:.*"

        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

        # wofi stayfocus
        "stayfocused,class:wofi"
        "opacity 1.15, class:^(firefox)$"
        "opacity 1.15, class:^(teams-for-linux)$"
        "opacity 1.15, class:^(librewolf)$"
      ];
    };
  };
}
