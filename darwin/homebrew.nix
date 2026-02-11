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
      "nvm"
      "podman"
      "podman-compose"
    ];

    casks = [
      "displaylink"
      "google-chrome"
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
