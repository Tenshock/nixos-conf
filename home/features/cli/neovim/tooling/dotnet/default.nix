{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    csharpier
    dotnet-sdk_9
  ];

  xdg.configFile."nvim/lua/tooling-plugins/dotnet.lua".source = ./config.lua;
}
