{ lib, ... }:
{
  catppuccin.hyprland.enable = false;

  home = {
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  imports = [
    ./bindings.nix
    ./ui.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false; # Necessary for UWSM integration. See nixos/hyprland.nix

    settings = {
      # Apps
      audioManager._var = "uwsm app -- $(kitty -e ncpamixer)";
      bluetoothManager._var = "uwsm app -- kitty -e bluetui";
      browser._var = "uwsm app -- zen-twilight";
      cbonsai._var = "uwsm app -- $(kitty -e cbonsai --live --time 0,2)";
      fileManager._var = "uwsm app -- thunar";
      hyprlock._var = "uwsm app -- hyprlock";
      networkManager._var = "uwsm app -- $(kitty -e nmtui)";
      obsidian._var = "uwsm app -- obsidian";
      smile._var = "uwsm app -- smile";
      statusbar._var = "uwsm app -- waybar";
      teams._var = "uwsm app -- teams-for-linux";
      terminal._var = "uwsm app -- kitty";
      walker._var = "uwsm app -- walker";

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
        {
          fingers = 4;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      monitor = [
        {
          output = "eDP-1";
          mode = "2880x1920@120";
          position = "auto";
          scale = 1.6;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          monitor = "eDP-1";
        }
      ];

      window_rule = [
        {
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_initial_focus = true;
          focus_on_activate = false;
        }
        {
          match.class = "wofi";
          stay_focused = true;
        }
        {
          match.class = "it.mijorus.smile";
          float = true;
          size = "520 620";
          center = true;
        }
      ];

      on._args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("[workspace 1 silent] " .. terminal)
          end
        '')
      ];

      config = {
        animations.enabled = false;

        dwindle = {
          preserve_split = true;
        };

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
      };
    };
  };
}
