{ config, ... }:
{
  home.sessionVariables.NH_FILE = "${config.xdg.configHome}/nixos/system.nix";

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
