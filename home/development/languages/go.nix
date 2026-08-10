{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [ go ];

    sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
      GOCACHE = "${config.xdg.cacheHome}/go-build";
    };
  };
}
