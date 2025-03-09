{ pkgs, ... }:
# TODO: add plugins dashlane, treestyletab
{
  programs.firefox.enable = true;
  programs.librewolf.enable = true;

  home.packages = with pkgs; [
    ladybird
  ];
}
