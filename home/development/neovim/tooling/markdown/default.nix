{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      ghostscript
      imagemagick
      markdown-toc
      markdownlint-cli2
      marksman
      mermaid-cli
      tectonic
    ];

    extras.lang.markdown.enable = true;
    plugins.tooling-markdown = builtins.readFile ./config.lua;
  };
}
