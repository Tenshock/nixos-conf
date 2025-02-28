{
  services.mako = {
    enable  = true;
    font    = "JetBrainsMono Nerd Font";
    format  = "<b>%a</b> - %s\n%b";
    sort    = "-time";

    ### Layout
    layer   = "overlay";
    width   = 300;
    height  = 110;
    margin = "5,0,0,0";
    padding = "0,5,10,10";
    borderSize = 2;
    borderRadius = 5;
    icons = true;

    ### Behavior
    defaultTimeout = 10000;
    ignoreTimeout = true;

    ### Colors
    backgroundColor = "#181825f0";
    textColor = "#cdd6f4";
    progressColor = "#313244";

    extraConfig = ''
      outer-margin=10,15,0,0

      [urgency=low]
      border-color=#8bd5ca

      [urgency=normal]
      border-color=#8aadf4

      [urgency=critical]
      border-color=#f38ba8
      default-timeout=0
    '';
  };
}
