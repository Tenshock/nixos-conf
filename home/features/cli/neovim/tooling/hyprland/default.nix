{ pkgs, ... }:
{
  programs.neovim.extraPackages = [ pkgs.hyprls ];

  xdg.configFile."nvim/lua/tooling-plugins/hyprland.lua".source = ./config.lua;
}
