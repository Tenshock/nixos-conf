{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    pyright
    python3
    python3Packages.debugpy
    ruff
  ];

  xdg.configFile."nvim/lua/tooling-extras/python.lua".source = ./extras.lua;
}
