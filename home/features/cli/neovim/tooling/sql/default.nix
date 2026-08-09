{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    sqlite
    sqlfluff
  ];

  xdg.configFile."nvim/lua/tooling-extras/sql.lua".source = ./extras.lua;
}
