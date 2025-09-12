{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font";
      format = "<b>%a</b> - %s\\n%b";
      sort = "-time";

      ### Layout
      layer = "overlay";
      width = 300;
      height = 110;
      margin = "5,0,0,0";
      padding = "0,5,10,10";
      border-size = 2;
      border-radius = 5;
      icons = true;

      ### Behavior
      default-timeout = 10000;
      ignore-timeout = true;

      ### Colors
      background-color = "#181825f0";
      text-color = "#cdd6f4";
      progress-color = "#313244";

      outer-margin = "10,15,0,0";
    };
    extraConfig = ''
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
