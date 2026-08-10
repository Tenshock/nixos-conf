{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    eslint
    nodejs_26
    oxfmt
    prettier
    svelte-language-server
    vscode-js-debug
    vscode-langservers-extracted
    vtsls
  ];

  xdg.configFile = {
    "nvim/lua/tooling-extras/js-ts.lua".source = ./extras.lua;
    "nvim/lua/tooling-plugins/js-ts.lua".source = ./config.lua;
  };
}
