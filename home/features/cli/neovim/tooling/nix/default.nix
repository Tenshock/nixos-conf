{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    nixd
    nixfmt
    statix
  ];

  xdg.configFile = {
    "nvim/lua/tooling-extras/nix.lua".source = ./extras.lua;
    "nvim/lua/tooling-plugins/nix.lua".source = ./config.lua;
  };
}
