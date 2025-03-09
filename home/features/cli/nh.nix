{ config, ... }: {
  programs.nh = {
    enable = true;
    flake = "${config.xdg.configHome}/nixos";
  };
}
