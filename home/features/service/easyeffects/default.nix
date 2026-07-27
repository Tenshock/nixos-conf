{ lib, pkgs, ... }:
let
  easyeffectsConfig = "\${XDG_CONFIG_HOME:-$HOME/.config}/easyeffects/db/easyeffectsrc";
  jsonFormat = pkgs.formats.json { };
in
{
  home.activation.easyeffectsRouting = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname "${easyeffectsConfig}")"

    set_easyeffects_key() {
      local group="$1"
      local key="$2"
      local value="$3"
      ${pkgs.gawk}/bin/awk -v group="$group" -v key="$key" -v value="$value" '
        BEGIN {
          section = "[" group "]"
        }
        $0 == section {
          in_section = 1
          found_section = 1
          print
          next
        }
        /^\[/ && in_section {
          if (!found_key) {
            print key "=" value
            found_key = 1
          }
          in_section = 0
        }
        in_section && index($0, key "=") == 1 {
          print key "=" value
          found_key = 1
          next
        }
        {
          print
        }
        END {
          if (found_section && in_section && !found_key) {
            print key "=" value
          } else if (!found_section) {
            print ""
            print section
            print key "=" value
          }
        }
      ' "${easyeffectsConfig}" > "${easyeffectsConfig}.tmp"
      mv "${easyeffectsConfig}.tmp" "${easyeffectsConfig}"
    }

    touch "${easyeffectsConfig}"
    set_easyeffects_key StreamInputs listenToMic false
    set_easyeffects_key StreamInputs listenToMicIncludesOutputEffects false
    set_easyeffects_key StreamInputs inputDevice alsa_input.usb-Logitech_Yeti_GX_2612SGN00W28-00.mono-fallback
    set_easyeffects_key StreamInputs blocklist electron
    set_easyeffects_key StreamInputs blocklistUsesMediaName false
    set_easyeffects_key StreamOutputs useDefaultOutputDevice true
    set_easyeffects_key StreamOutputs blocklist electron
    set_easyeffects_key StreamOutputs blocklistUsesMediaName false
  '';

  services.easyeffects = {
    enable = true;
    preset = "home";
  };

  xdg.dataFile."easyeffects/input/home.json".source = jsonFormat.generate "input-home.json" {
    input = import ./input.nix;
  };
  xdg.dataFile."easyeffects/output/home.json".source = jsonFormat.generate "output-home.json" {
    output = import ./output.nix;
  };
}
