{ pkgs, ... }:
{
  programs.lazyvim.extraPackages = with pkgs; [
    lua-language-server
    stylua
  ];
}
