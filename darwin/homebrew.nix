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
      "nvm"
    ];

    casks = [
      "codex-app"
      "displaylink"
      "docker-desktop"
      "linear"
      "zen"
    ];

    masApps = {
      "Keynote" = 409183694;
      "Xcode" = 497799835;
    };
  };
}
