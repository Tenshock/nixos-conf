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
        "gate#0"
        "filter#0"
        "compressor#0"
        "deesser#0"
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
        bypass = true;
        input-gain = 0.0;
        max-df-processing-threshold = 20.0;
        max-erb-processing-threshold = 30.0;
        min-processing-buffer = 0;
        min-processing-threshold = 5.0;
        output-gain = 0.0;
        post-filter-beta = 0.019999999552965164;
      };
      "gate#0" = {
        attack = 20.0;
        bypass = true;
        curve-threshold = -58.0;
        curve-zone = -6.0;
        dry = -80.01;
        hpf-frequency = 10.0;
        hpf-mode = "Off";
        hysteresis = true;
        hysteresis-threshold = -66.0;
        hysteresis-zone = 0.0;
        input-gain = 0.0;
        input-to-link = -80.01;
        input-to-sidechain = -80.01;
        link-to-input = -80.01;
        link-to-sidechain = -80.01;
        lpf-frequency = 20000.0;
        lpf-mode = "Off";
        makeup = 0.0;
        output-gain = 0.0;
        reduction = -36.0;
        release = 100.0;
        sidechain = {
          lookahead = 0.0;
          mode = "Peak";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Feed-forward";
        };
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        stereo-split = false;
        wet = 0.0;
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
      "deesser#0" = {
        bypass = true;
        detection = "RMS";
        f1-freq = 6000.0;
        f1-level = 0.0;
        f2-freq = 4500.0;
        f2-level = 12.0;
        f2-q = 1.0;
        input-gain = 0.0;
        laxity = 15;
        makeup = 0.0;
        mode = "Wide";
        output-gain = 0.0;
        ratio = 3.0;
        sc-listen = false;
        threshold = -18.0;
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
    extraPresets."Studio".input = {
      blocklist = [ "electron" ];
      plugins_order = [
        "echo_canceller#0"
        "rnnoise#0"
        "deepfilternet#0"
        "gate#0"
        "equalizer#0"
        "compressor#0"
        "deesser#0"
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
        enable-vad = false;
        input-gain = 0.0;
        model-name = "\"\"";
        output-gain = 0.0;
        release = 20.0;
        use-standard-model = true;
        vad-thres = 30.0;
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
      "gate#0" = {
        attack = 5.0;
        bypass = false;
        curve-threshold = -50.0;
        curve-zone = -2.0;
        dry = -80.01;
        hpf-frequency = 10.0;
        hpf-mode = "Off";
        hysteresis = true;
        hysteresis-threshold = -3.0;
        hysteresis-zone = -1.0;
        input-gain = 0.0;
        input-to-link = 0.0;
        input-to-sidechain = 0.0;
        link-to-input = 0.0;
        link-to-sidechain = 0.0;
        lpf-frequency = 20000.0;
        lpf-mode = "Off";
        makeup = 1.0;
        output-gain = 0.0;
        reduction = -12.0;
        release = 250.0;
        sidechain = {
          lookahead = 0.0;
          mode = "RMS";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Internal";
        };
        sidechain-to-input = 0.0;
        sidechain-to-link = 0.0;
        stereo-split = false;
        wet = -1.0;
      };
      "equalizer#0" = {
        balance = 0.1;
        bypass = false;
        input-gain = 0.0;
        left = {
          band0 = {
            frequency = 80.0;
            gain = 0.0;
            mode = "RLC (BT)";
            mute = false;
            q = 0.7;
            slope = "x2";
            solo = false;
            type = "Hi-pass";
            width = 4.0;
          };
          band1 = {
            frequency = 220.0;
            gain = -2.0;
            mode = "RLC (MT)";
            mute = false;
            q = 0.7;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band2 = {
            frequency = 350.0;
            gain = -2.0;
            mode = "BWC (MT)";
            mute = false;
            q = 1.2;
            slope = "x2";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band3 = {
            frequency = 3500.0;
            gain = 2.0;
            mode = "BWC (BT)";
            mute = false;
            q = 0.9;
            slope = "x2";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band4 = {
            frequency = 10000.0;
            gain = 2.0;
            mode = "LRX (MT)";
            mute = false;
            q = 0.7;
            slope = "x1";
            solo = false;
            type = "Hi-shelf";
            width = 4.0;
          };
        };
        mode = "IIR";
        num-bands = 5;
        output-gain = 0.0;
        pitch-left = 0.0;
        pitch-right = 0.0;
        right = {
          band0 = {
            frequency = 80.0;
            gain = 0.0;
            mode = "RLC (BT)";
            mute = false;
            q = 0.7;
            slope = "x2";
            solo = false;
            type = "Hi-pass";
            width = 4.0;
          };
          band1 = {
            frequency = 220.0;
            gain = -2.0;
            mode = "RLC (MT)";
            mute = false;
            q = 0.7;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band2 = {
            frequency = 350.0;
            gain = -2.0;
            mode = "BWC (MT)";
            mute = false;
            q = 1.2;
            slope = "x2";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band3 = {
            frequency = 3500.0;
            gain = 2.0;
            mode = "BWC (BT)";
            mute = false;
            q = 0.9;
            slope = "x2";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band4 = {
            frequency = 10000.0;
            gain = 2.0;
            mode = "LRX (MT)";
            mute = false;
            q = 0.7;
            slope = "x1";
            solo = false;
            type = "Hi-shelf";
            width = 4.0;
          };
        };
        split-channels = false;
      };
      "compressor#0" = {
        attack = 15.0;
        boost-amount = 0.0;
        boost-threshold = -72.0;
        bypass = false;
        dry = -80.01;
        hpf-frequency = 10.0;
        hpf-mode = "Off";
        input-gain = 0.0;
        input-to-link = 0.0;
        input-to-sidechain = 0.0;
        knee = -6.0;
        link-to-input = 0.0;
        link-to-sidechain = 0.0;
        lpf-frequency = 20000.0;
        lpf-mode = "Off";
        makeup = 3.0;
        mode = "Downward";
        output-gain = 0.0;
        ratio = 3.0;
        release = 200.0;
        release-threshold = -40.0;
        sidechain = {
          lookahead = 0.0;
          mode = "RMS";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Feed-forward";
        };
        sidechain-to-input = 0.0;
        sidechain-to-link = 0.0;
        stereo-split = false;
        threshold = -18.0;
        wet = 0.0;
      };
      "deesser#0" = {
        bypass = false;
        detection = "RMS";
        f1-freq = 4000.0;
        f1-level = -6.0;
        f2-freq = 8000.0;
        f2-level = -6.0;
        f2-q = 1.5;
        input-gain = 0.0;
        laxity = 15;
        makeup = 0.0;
        mode = "Split";
        output-gain = 0.0;
        ratio = 3.0;
        sc-listen = false;
        threshold = -22.0;
      };
      "limiter#0" = {
        alr = false;
        alr-attack = 5.0;
        alr-knee = 0.0;
        alr-release = 50.0;
        attack = 2.0;
        bypass = false;
        dithering = "16bit";
        gain-boost = false;
        input-gain = 0.0;
        input-to-link = 0.0;
        input-to-sidechain = 0.0;
        link-to-input = 0.0;
        link-to-sidechain = 0.0;
        lookahead = 2.0;
        mode = "Herm Wide";
        output-gain = 0.0;
        oversampling = "None";
        release = 5.0;
        sidechain-preamp = 0.0;
        sidechain-to-input = 0.0;
        sidechain-to-link = 0.0;
        sidechain-type = "Internal";
        stereo-link = 100.0;
        threshold = -1.5;
      };
    };
  };
}
