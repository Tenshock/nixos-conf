{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    go
    gopls
  ];

  xdg.configFile."nvim/lua/tooling-plugins/go.lua".source = ./config.lua;
}
