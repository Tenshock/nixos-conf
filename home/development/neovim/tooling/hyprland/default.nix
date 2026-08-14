{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = [ pkgs.hyprls ];
    treesitterParsers = [ pkgs.vimPlugins.nvim-treesitter-parsers.hyprlang ];

    plugins.tooling-hyprland = builtins.readFile ./config.lua;
  };
}
