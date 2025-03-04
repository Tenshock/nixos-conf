{ config, ... }:
let
  wallpaperDir = ../../../wallpapers;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${config.xdg.configHome}/wallpapers/wallpaper-2.png"
      ];
      wallpaper = [
        ",${config.xdg.configHome}/wallpapers/wallpaper-2.png"
      ];
    };
  };

  home.file.".wallpapers" = {
    source = wallpaperDir;
    target = "${config.xdg.configHome}/wallpapers";
  };
}
