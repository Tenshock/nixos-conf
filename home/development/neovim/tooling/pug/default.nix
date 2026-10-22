{ pkgs, ... }:
{
  programs.lazyvim = {
    plugins.tooling-pug = builtins.readFile ./config.lua;
    treesitterParsers = [ pkgs.vimPlugins.nvim-treesitter-parsers.pug ];
  };
}
