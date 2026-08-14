{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = [ pkgs.shfmt ];
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      ini
      zsh
    ];

    plugins.tooling-shell = builtins.readFile ./config.lua;
  };
}
