{
  nixpkgs = {
    config.allowUnfree = true;
    # TODO: Remove this whenvulnerability from pnpm is fixed: https://github.com/NixOS/nixpkgs/issues/536623
    overlays = [
      (final: prev: {
        vesktop = prev.vesktop.override {
          pnpm_10_29_2 = final.pnpm_10;
        };
      })
    ];
  };

  nix = {
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
