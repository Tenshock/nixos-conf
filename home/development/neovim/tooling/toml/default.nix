{ pkgs, ... }:
{
  programs.neovim.extraPackages = [ pkgs.taplo ];

  xdg.configFile."nvim/lua/tooling-extras/toml.lua".source = ./extras.lua;
}
