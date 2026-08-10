{ pkgs, ... }:
{
  programs.neovim.extraPackages = [ pkgs.helm-ls ];

  xdg.configFile = {
    "nvim/lua/tooling-extras/helm.lua".source = ./extras.lua;
    "nvim/lua/tooling-plugins/helm.lua".source = ./config.lua;
  };
}
