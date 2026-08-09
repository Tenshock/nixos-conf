{
  pkgs,
  sources,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    channel.enable = false;

    nixPath = [ "nixpkgs=${sources.nixpkgs.outPath}" ];

    settings = {
      experimental-features = [ "nix-command" ];
      auto-optimise-store = true;
    };

    optimise.automatic = true;
  };

  system.nixos = {
    revision = sources.nixpkgs.revision;
    versionSuffix = ".${builtins.substring 0 7 sources.nixpkgs.revision}";
  };

  services.envfs.enable = true;
}
