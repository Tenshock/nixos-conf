{ pkgs, ... }:
{
  programs.neovim.extraPackages = [ pkgs.shfmt ];

  xdg.configFile."nvim/lua/tooling-plugins/shell.lua".source = ./config.lua;
}
