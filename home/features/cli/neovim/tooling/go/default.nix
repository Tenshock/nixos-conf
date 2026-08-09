{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    delve
    go
    gofumpt
    golangci-lint
    gopls
    gotools
  ];

  xdg.configFile."nvim/lua/tooling-extras/go.lua".source = ./extras.lua;
}
