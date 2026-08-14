{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = [ pkgs.taplo ];

    extras.lang.toml.enable = true;
  };
}
