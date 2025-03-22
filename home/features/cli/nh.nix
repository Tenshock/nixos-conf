{ config, ... }: {
  programs.nh = {
    enable = true;
    flake = "${config.xdg.configHome}/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
