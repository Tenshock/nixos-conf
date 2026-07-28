{ ... }:
{
  disabledModules = [ "services/easyeffects.nix" ];

  imports = [
    /home/cedric/projects/own/home-manager/modules/services/easyeffects.nix
  ];

  services.easyeffects = {
    enable = true;
    preset = "home";
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
