{
  xdg.configFile = {
    "vesktop/userAssets/tray".source = ../service/waybar/style/icons/vesktop-brand-discord-red.png;
    "vesktop/userAssets/trayUnread".source =
      ../service/waybar/style/icons/vesktop-brand-discord-red.png;
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
