{
  services.easyeffects = {
    enable = true;
    preset = {
      input = "home";
      output = "Discord Voice";
    };
    extraPresets = {
      home = import ./home.nix;
      "Discord Voice" = import ./discord-voice.nix;
    };
    settings = {
      EffectsPipelines.bypass = false;

      Window.autostartOnLogin = false;

      StreamInputs = {
        blocklist = null;
        useDefaultInputDevice = true;
        listenToMic = false;
        listenToMicIncludesOutputEffects = false;
        blocklistUsesMediaName = false;
      };
      StreamOutputs = {
        blocklist = null;
        useDefaultOutputDevice = true;
        blocklistUsesMediaName = false;
      };
    };
  };

  xdg.configFile."autostart/com.github.wwmm.easyeffects.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Easy Effects
      Hidden=true
    '';
  };
}
