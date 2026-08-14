{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = [ pkgs.helm-ls ];

    extras.lang.helm.enable = true;
    plugins.tooling-helm = builtins.readFile ./config.lua;
  };
}
