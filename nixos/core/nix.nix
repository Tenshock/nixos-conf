{ pkgs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    optimise.automatic = true;
  };

  services.envfs.enable = true;
}
