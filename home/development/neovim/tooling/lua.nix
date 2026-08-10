{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    lua-language-server
    stylua
  ];
}
