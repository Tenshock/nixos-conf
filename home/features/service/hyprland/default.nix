{ lib, pkgs, ... }:
let
  hyprlandGpuProfile = pkgs.callPackage ./gpu-profile.nix { };
in
{
  catppuccin.hyprland.enable = false;

  home = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    packages = [ hyprlandGpuProfile ];
  };

  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRLAND_GPU_PROFILE="''${HYPRLAND_GPU_PROFILE:-igpu}"
    export HYPRLAND_APP_PROFILE="''${HYPRLAND_APP_PROFILE:-default}"

    amd="/dev/dri/amd-igpu"
    nvidia="/dev/dri/nvidia-egpu"

    if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ]; then
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        [ -e "$nvidia" ] && break
        sleep 1
      done

      if [ -e "$nvidia" ]; then
        export AQ_DRM_DEVICES="$nvidia:$amd"
      else
        export AQ_DRM_DEVICES="$amd"
      fi
    elif [ -e "$nvidia" ]; then
      export AQ_DRM_DEVICES="$amd:$nvidia"
    else
      export AQ_DRM_DEVICES="$amd"
    fi

    export AQ_FORCE_LINEAR_BLIT=0
  '';

  services.hyprpolkitagent.enable = true;

  imports = [
    ./apps.nix
    ./bindings.nix
    ./ui.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false; # Necessary for UWSM integration. See nixos/hyprland.nix
    extraConfig = ''
      pcall(require, "monitors")
    '';

    xdph.settings.screencopy = {
      allow_token_by_default = true;
      cursor_mode = 2;
    };

    settings = {
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

      workspace_rule = [
        {
          workspace = "1";
          monitor = "eDP-1";
        }
        {
          workspace = "2";
          monitor = "desc:Dell Inc. DELL P2425DE 769WZB4";
        }
        {
          workspace = "3";
          monitor = "desc:Dell Inc. DELL P2425D 68BZZB4";
        }
        {
          workspace = "4";
          monitor = "eDP-1";
        }
        {
          workspace = "5";
          monitor = "desc:Dell Inc. DELL P2425D 68BZZB4";
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
          match.class = "walker";
          stay_focused = true;
        }
        {
          match.title = "Archive password";
          stay_focused = true;
          focus_on_activate = true;
        }
        {
          match.title = "gsimplecal";
          float = true;
          border_color = "rgba(0f111abf) rgba(0f111abf)";
          move = "6 34";
          size = "306 180";
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
            local app_profile = os.getenv("HYPRLAND_APP_PROFILE") or "default"

            hl.exec_cmd("${lib.getExe hyprlandGpuProfile}")
            hl.exec_cmd(loginToOnePassword)
            hl.exec_cmd(terminal, { workspace = "1 silent" })

            if app_profile == "work" then
              hl.exec_cmd(mattermost, { workspace = "2 silent" })
              hl.exec_cmd(tchap, { workspace = "2 silent" })
              hl.exec_cmd(vesktop, { workspace = "2 silent" })
              hl.exec_cmd(obsidian, { workspace = "3 silent" })
            end

            hl.exec_cmd(browser, { workspace = "4 silent" })
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
