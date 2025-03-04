{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    hyprshot
  ];

  xdg = {
    userDirs.extraConfig = {
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures";
    };
  };
}
