{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    tinymist
    typst
    typstyle
  ];

  xdg.configFile."nvim/lua/tooling-extras/typst.lua".source = ./extras.lua;
}
