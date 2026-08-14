{ pkgs, ... }:
{
  programs = {
    lazyvim = {
      extraPackages = with pkgs; [
        csharpier
        dotnet-sdk_10
        fantomas
        fsautocomplete
        netcoredbg
        roslyn-ls
      ];

      extras.lang.dotnet.enable = true;
      plugins.tooling-dotnet = builtins.readFile ./config.lua;
    };
  };
}
