{ pkgs, ... }:
{
  home.packages = with pkgs; [
    csharpier
    dotnet-sdk_9
  ];
}
