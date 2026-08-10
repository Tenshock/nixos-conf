{
  xdg.configFile = {
    "vesktop/userAssets/tray".source = ../desktop/waybar/style/icons/vesktop-brand-discord-red.png;
    "vesktop/userAssets/trayUnread".source =
      ../desktop/waybar/style/icons/vesktop-brand-discord-red.png;
  };

  programs.vesktop = {
    enable = true;
    vencord.settings = {
      plugins = {
        FakeNitro.enabled = true;
      };
    };
  };

  catppuccin.vesktop.enable = true;
}
