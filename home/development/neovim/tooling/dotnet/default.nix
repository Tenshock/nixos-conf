{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    csharpier
    dotnet-sdk_10
    fantomas
    fsautocomplete
    netcoredbg
    roslyn-ls
  ];
  programs.neovim.extraWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${pkgs.dotnet-sdk_10}/bin"
  ];

  xdg.configFile."nvim/lua/tooling-extras/dotnet.lua".source = ./extras.lua;
  xdg.configFile."nvim/lua/tooling-plugins/dotnet.lua".source = ./config.lua;
}
