{
  services.easyeffects = {
    enable = true;
    preset = "Yeti GX";
    extraPresets."Yeti GX".input = {
      blocklist = [ ];
      "compressor#0" = {
        attack = 10.0;
        boost-amount = 6.0;
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
        makeup = 0.0;
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
      "gate#0" = {
        attack = 20.0;
        bypass = true;
        curve-threshold = -50.0;
        curve-zone = -6.0;
        dry = -80.01;
        hpf-frequency = 10.0;
        hpf-mode = "Off";
        hysteresis = true;
        hysteresis-threshold = -58.0;
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
        reduction = -24.0;
        release = 100.0;
        sidechain = {
          lookahead = 0.0;
          mode = "Peak";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "External";
        };
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        stereo-split = false;
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
        gain-boost = true;
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
      plugins_order = [
        "rnnoise#0"
        "gate#0"
        "filter#0"
        "compressor#0"
        "deesser#0"
        "limiter#0"
      ];
      "rnnoise#0" = {
        bypass = false;
        enable-vad = true;
        input-gain = 0.0;
        model-name = "\"\"";
        output-gain = 0.0;
        release = 200.0;
        use-standard-model = true;
        vad-thres = 40.0;
        wet = 0.0;
      };
    };
  };
}
