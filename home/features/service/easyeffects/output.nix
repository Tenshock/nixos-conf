{
  blocklist = [ "electron" ];
  plugins_order = [
    "compressor#0"
    "limiter#0"
  ];
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
    makeup = 4.0;
    mode = "Downward";
    output-gain = 0.0;
    ratio = 3.0;
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
    threshold = -24.0;
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
    release = 50.0;
    sidechain-preamp = 0.0;
    sidechain-to-input = -80.01;
    sidechain-to-link = -80.01;
    sidechain-type = "Internal";
    stereo-link = 100.0;
    threshold = -1.0;
  };
}
