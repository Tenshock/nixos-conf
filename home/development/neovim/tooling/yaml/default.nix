{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = [ pkgs.yaml-language-server ];

    extras.lang.yaml.enable = true;
    plugins.tooling-yaml = builtins.readFile ./config.lua;
  };
}
