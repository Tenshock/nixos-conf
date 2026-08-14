{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      delve
      go
      gofumpt
      golangci-lint
      gopls
      gotools
    ];

    extras.lang.go.enable = true;
  };
}
