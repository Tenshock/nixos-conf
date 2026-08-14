{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      pyright
      python3
      python3Packages.debugpy
      ruff
    ];

    extras.lang.python.enable = true;
  };
}
