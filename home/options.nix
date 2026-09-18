{ config, lib, ... }:
{
  options.dotfiles.repositoryRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.config/nixos";
    description = "Absolute path to the writable dotfiles repository checkout.";
  };

  options.dotfiles.waybar.cpuCoreCount = lib.mkOption {
    type = lib.types.ints.positive;
    default = 12;
    description = "Number of logical CPU cores shown in Waybar.";
  };

  config.assertions = [
    {
      assertion = lib.hasPrefix "/" config.dotfiles.repositoryRoot;
      message = "dotfiles.repositoryRoot must be an absolute path.";
    }
    {
      assertion = builtins.pathExists config.dotfiles.repositoryRoot;
      message = "dotfiles.repositoryRoot does not exist: ${config.dotfiles.repositoryRoot}";
    }
  ];
}
