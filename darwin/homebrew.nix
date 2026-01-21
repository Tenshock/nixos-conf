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
      "linear-linear"
      "mongodb-compass"
      "notion"
      "obsidian"
      "postman"
      "zen"
    ];

    masApps = {
      "Slack" = 803453959;
      "WhatsApp" = 310633997;
      "Keynote" = 409183694;
    };
  };
}
