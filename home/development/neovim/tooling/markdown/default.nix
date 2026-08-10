{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    ghostscript
    imagemagick
    markdown-toc
    markdownlint-cli2
    marksman
    mermaid-cli
    tectonic
  ];

  xdg.configFile = {
    "nvim/lua/tooling-extras/markdown.lua".source = ./extras.lua;
    "nvim/lua/tooling-plugins/markdown.lua".source = ./config.lua;
  };
}
