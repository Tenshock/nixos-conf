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
}
