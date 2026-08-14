{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      nixd
      nixfmt
      statix
    ];

    extras.lang.nix.enable = true;
    plugins.tooling-nix = builtins.readFile ./config.lua;
  };
}
