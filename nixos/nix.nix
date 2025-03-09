{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    optimise.automatic = true;
    gc = {

      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  services.envfs.enable = true;
}
