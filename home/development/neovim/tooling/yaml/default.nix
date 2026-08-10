{ pkgs, ... }:
{
  programs.neovim.extraPackages = [ pkgs.yaml-language-server ];

  xdg.configFile = {
    "nvim/lua/tooling-extras/yaml.lua".source = ./extras.lua;
    "nvim/lua/tooling-plugins/yaml.lua".source = ./config.lua;
  };
}
