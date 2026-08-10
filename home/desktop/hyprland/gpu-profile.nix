{
  hyprland,
  jq,
  writeShellApplication,
}:

writeShellApplication {
  name = "hyprland-gpu-profile";
  runtimeInputs = [
    jq
    hyprland
  ];
  text = ''
    profile="''${HYPRLAND_GPU_PROFILE:-igpu}"

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
}
