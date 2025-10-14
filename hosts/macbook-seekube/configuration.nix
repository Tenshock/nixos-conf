user: {pkgs, ...}: {

  nix.settings.experimental-features = "nix-command flakes";

  system = {
    primaryUser = user;
    stateVersion = 6;
    activationScripts = {
      rosettaInstall.text = ''
        softwareupdate --install-rosetta --agree-to-license
      '';
    };
  };

  homebrew = {
    enable = true;

    brews = [
      "mas"
    ];

    casks = [
      "zen"
      "notion"
    ];

    masApps = {
      "Slack" = 803453959;
    };
  };


  nixpkgs.hostPlatform = "aarch64-darwin";
}
