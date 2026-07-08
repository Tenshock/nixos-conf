{ lib, pkgs, ... }:
let
  easyeffectsConfig = "$HOME/.config/easyeffects/db/easyeffectsrc";
in
{
  home.activation.easyeffectsDiscordBypass = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    set_easyeffects_key StreamOutputs outputDevice alsa_output.pci-0000_c1_00.6.analog-stereo
    set_easyeffects_key StreamOutputs blocklist electron
    set_easyeffects_key StreamOutputs blocklistUsesMediaName false
  '';

  services.easyeffects = {
    enable = true;
    preset = "Yeti GX";
    extraPresets."Yeti GX".input = {
      blocklist = [ "electron" ];
      plugins_order = [
        "echo_canceller#0"
        "rnnoise#0"
        "deepfilternet#0"
        "filter#0"
        "compressor#0"
        "limiter#0"
      ];
      "echo_canceller#0" = {
        bypass = false;
        input-gain = 0.0;
        output-gain = 0.0;
        echo-canceller = {
          enable = true;
          mobile-mode = false;
          enforce-high-pass = true;
          automatic-gain-control = true;
        };
        noise-suppression = {
          enable = true;
          level = "Moderate";
        };
        high-pass = {
          enable = true;
          full-band = true;
        };
      };
      "rnnoise#0" = {
        bypass = false;
        enable-vad = true;
        input-gain = 0.0;
        model-name = "\"\"";
        output-gain = 0.0;
        release = 200.0;
        use-standard-model = true;
        vad-thres = 60.0;
        wet = 0.0;
      };
      "deepfilternet#0" = {
        attenuation-limit = 100.0;
        bypass = false;
        input-gain = 0.0;
        max-df-processing-threshold = 20.0;
        max-erb-processing-threshold = 30.0;
        min-processing-buffer = 0;
        min-processing-threshold = 5.0;
        output-gain = 0.0;
        post-filter-beta = 0.019999999552965164;
      };
      "filter#0" = {
        balance = 0.0;
        bypass = false;
        equal-mode = "IIR";
        frequency = 70.0;
        gain = 0.0;
        input-gain = 0.0;
        mode = "BWC (BT)";
        output-gain = 0.0;
        quality = 0.0;
        slope = "x2";
        type = "High-pass";
        width = 4.0;
      };
      "compressor#0" = {
        attack = 10.0;
        boost-amount = 0.0;
        boost-threshold = -72.0;
        bypass = false;
        dry = -80.01;
        hpf-frequency = 10.0;
        hpf-mode = "Off";
        input-gain = 0.0;
        input-to-link = -80.01;
        input-to-sidechain = -80.01;
        knee = -6.0;
        link-to-input = -80.01;
        link-to-sidechain = -80.01;
        lpf-frequency = 20000.0;
        lpf-mode = "Off";
        makeup = 12.0;
        mode = "Downward";
        output-gain = 0.0;
        ratio = 2.0;
        release = 150.0;
        release-threshold = -60.0;
        sidechain = {
          lookahead = 0.0;
          mode = "RMS";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Feed-forward";
        };
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        stereo-split = false;
        threshold = -18.0;
        wet = 0.0;
      };
      "limiter#0" = {
        alr = false;
        alr-attack = 5.0;
        alr-knee = 0.0;
        alr-knee-smooth = -5.0;
        alr-release = 50.0;
        attack = 1.0;
        bypass = false;
        dithering = "None";
        gain-boost = false;
        input-gain = 0.0;
        input-to-link = -80.01;
        input-to-sidechain = -80.01;
        link-to-input = -80.01;
        link-to-sidechain = -80.01;
        lookahead = 5.0;
        mode = "Herm Thin";
        output-gain = 0.0;
        oversampling = "None";
        release = 20.0;
        sidechain-preamp = 0.0;
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        sidechain-type = "Internal";
        stereo-link = 100.0;
        threshold = -1.0;
      };
    };
  };
}
