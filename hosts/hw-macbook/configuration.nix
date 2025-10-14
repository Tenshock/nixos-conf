user: {
  nix.settings.experimental-features = "nix-command flakes";

  system = {
    primaryUser = user;
    stateVersion = 6;
    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';

  };

  homebrew = {
    enable = true;

    brews = [];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
