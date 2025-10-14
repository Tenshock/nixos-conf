{
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    optimise.automatic = true;
  };
}
