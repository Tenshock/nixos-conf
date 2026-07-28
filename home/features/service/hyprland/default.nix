{ lib, pkgs, ... }:
let
  hyprlandGpuProfile = pkgs.writeShellApplication {
    name = "hyprland-gpu-profile";
    runtimeInputs = with pkgs; [
      jq
      hyprland
    ];
    text = ''
      profile="''${HYPRLAND_GPU_PROFILE:-mobile}"

      vendor_for_output() {
        output="$1"

        case "$output" in
          *[!A-Za-z0-9_-]*)
            return
            ;;
        esac

        for connector in "/sys/class/drm"/card*-"$output"; do
          [ -e "$connector/device/vendor" ] || continue
          cat "$connector/device/vendor"
          return
        done
      }

      disable_output() {
        output="$1"

        case "$output" in
          *[!A-Za-z0-9_-]*)
            return
            ;;
        esac

        hyprctl -q eval "hl.monitor({ output = \"$output\", disabled = true })" || true
      }

      for _ in 1 2 3 4 5 6 7 8 9 10; do
        monitors="$(hyprctl monitors all -j 2>/dev/null || true)"
        [ -n "$monitors" ] && break
        sleep 1
      done

      [ -n "''${monitors:-}" ] || exit 0

      printf '%s\n' "$monitors" | jq -r '.[] | [.name, .description] | @tsv' | while IFS="$(printf '\t')" read -r output description; do
        vendor="$(vendor_for_output "$output")"

        if [ "$profile" = "egpu" ]; then
          case "$vendor:$output:$description" in
            0x1002:eDP-*:*)
              ;;
            0x1002:*)
              disable_output "$output"
              ;;
            0x10de:DP-*:*"Dell Inc. DELL P2425D 68BZZB4"*)
              disable_output "$output"
              ;;
          esac
        else
          [ "$vendor" = "0x10de" ] && disable_output "$output"
        fi
      done
    '';
  };
in
{
  catppuccin.hyprland.enable = false;

  home = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    packages = [ hyprlandGpuProfile ];
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRLAND_GPU_PROFILE="''${HYPRLAND_GPU_PROFILE:-mobile}"

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
            hl.exec_cmd("${lib.getExe hyprlandGpuProfile}")
            hl.exec_cmd(terminal, { workspace = "1" })
            hl.exec_cmd(mattermost, { workspace = "2" })
            hl.exec_cmd(tchap, { workspace = "2" })
            hl.exec_cmd(vesktop, { workspace = "2" })
            hl.exec_cmd(obsidian, { workspace = "3" })
            hl.exec_cmd(browser, { workspace = "4" })
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
