{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      sqlite
      sqlfluff
    ];

    extras.lang.sql.enable = true;
  };
}
