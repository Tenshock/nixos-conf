{
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = false;
    };

    brews = [
      "docker"
      "docker-compose"
      "mas"
      "mongosh"
      "nvm"
      "podman"
      "podman-compose"
    ];

    casks = [
      "displaylink"
      "docker-desktop"
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
      "Xcode" = 497799835;
    };
  };
}
