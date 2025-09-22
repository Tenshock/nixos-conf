user: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  system = {
    primaryUser = user;
    stateVersion = 6;
  };

  homebrew = {
    enable = true;

    brews = [
      "awscli"
      "cli53"
    ];
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
