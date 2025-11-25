{
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = false;
    };

    brews = [
      "mas"
      "mongosh"
      "podman"
      "podman-compose"
    ];

    casks = [
      "displaylink"
      "kdenlive"
      "linear-linear"
      "mongodb-compass"
      "notion"
      "obsidian"
      "zen"
    ];

    masApps = {
      "Slack" = 803453959;
      "WhatsApp" = 310633997;
      "Keynote" = 409183694;
    };
  };
}
