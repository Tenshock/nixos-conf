{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      tinymist
      typst
      typstyle
    ];

    extras.lang.typst.enable = true;
  };
}
