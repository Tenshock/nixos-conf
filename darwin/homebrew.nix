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
      "podman"
      "podman-compose"
    ];

    casks = [
      "codex-app"
      "displaylink"
      "docker-desktop"
      "linear-linear"
    ];

    masApps = {
      "Keynote" = 409183694;
      "Xcode" = 497799835;
    };
  };
}
